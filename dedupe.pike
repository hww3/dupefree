


int main(int argc, array argv)
{
	mapping c = ([]);
	
	c->dir = argv[1];
	c->moveto = argv[2];
	
	dedupe(c);
	return 0;
}

int dirs = 0;
int files = 0;
int saved_bytes = 0;

multiset exts_to_skip = (<"app", "framework", "svn">);

mapping keys = ([]);
mapping suspects = ([]);
mapping true_dupes = ([]);
mapping truncated_dupes = ([]);

function report_dir = my_report_dir;
function report_file = my_report_file;

void my_report_file(string dir)
{
	if((files%10)==0) write(".");
//	write("\nconsidering " + dir + "\n");
}

void my_report_dir(string dir)
{
	write("entering " + dir + "\n");
}


int dedupe(mapping config)
{
	object fs = Filesystem.System(config->dir);
	
	scan(fs);
	werror("have %d suspects.\n", sizeof(suspects));
	
	werror("suspects: %O\n", suspects);
    write("examining suspected duplicates");
	foreach(suspects;; array suspect)
	{
	  examine_suspect(suspect);
	}
    werror("\n");
	werror("true dupes: %O\n", true_dupes);
	werror("truncated dupes: %O\n", truncated_dupes);
	werror("considered %d files in %d folders.\n", files, dirs);
	werror("%d kilobytes could be saved by deleting %d duplicates.", saved_bytes/1024, sizeof(true_dupes));

    string script = "";

    foreach(true_dupes;; array d)
	{
		array y = sort(d);
		script += ("# " + y[0] + "\n");
		foreach(y[1..];; string f)
		  script += ("rm \"" + f + "\"\n");
		script +="\n";
	}
	
	Stdio.write_file("cleanup_script.sh", script);
}

int sf = 0;

void examine_suspect(array hits)
{
  mapping wd = ([]);
  mapping sd = ([]);
  sf++;

  if((sf%10) == 0) write(".");
  // get the true duplicates
  foreach(hits;;string hit)
  {
	Stdio.File hf = Stdio.File(hit, "r");
    int hs = 0;
	string hd = "";
	Crypto.MD5 hh = Crypto.MD5();
	
	// don't read the whole file into a string, we might not have enough memory. 
	// add to the hash 100k at a time.
	do
	{
		hd = hf->read(1024*100);
		hh->update(hd);
		hs += sizeof(hd);
	} while(sizeof(hd));
	
	string hash = hh->digest();
	sd[hit] = hs;
	
    if(true_dupes[hash])
	{
		true_dupes[hash] += ({hit});
		saved_bytes += sd[hit];
	}
    else if(wd[hash])
    {
	   true_dupes[hash] = ({wd[hash], hit});
		saved_bytes += sd[hit];
    }
    else
    {
        wd[hash] = hit;
    }
  }

  // now, let's look for files that have identical content as the shortest base file,
  // such a partially downloaded file.

  array sdv = values(sd);
  array sdi = indices(sd);

  sort(sdv, sdi);

  // the reference file is the shortest
  string ref = sdi[0];
  int rs = sdv[0]; // rs is the size of the shortest file with the common hash.

  Stdio.File hfr = Stdio.File(ref, "r");
  int hsr = 0;
  string hdr = "";
  Crypto.MD5 hhr = Crypto.MD5();
	
	// don't read the whole file into a string, we might not have enough memory. 
	// add to the hash 100k at a time.
  do
  {
	hdr = hfr->read(1024*100);
	hhr->update(hdr);
	hsr += sizeof(hdr);
  } while(sizeof(hdr));
	
  string rh = hhr->digest();

  array share_common_base = ({});

  foreach(sdi[1..];; string cf)
  {
	Stdio.File ccf = Stdio.File(cf, "r");
    int chs = 0;
	string chd = "";
	Crypto.MD5 chh = Crypto.MD5();

	// don't read the whole file into a string, we might not have enough memory. 
	// add to the hash 100k at a time.
	int ltr = rs;
	int toread;
	do
	{
		if(ltr > (1024*100))
		  toread = (1024*100);
		else toread = ltr;
		chd = ccf->read(toread);
		
		chh->update(chd);
		chs += sizeof(chd);
	} while(ltr && sizeof(chd));

	string ch = chh->digest();
	
	  if(rh == ch && (sd[cf] != hsr)) // only if they have identical common beginnings and are of different lengths
	  {
     	share_common_base += ({cf});
	  }
  }  

// werror("share_common_base: %O\n", share_common_base);
  if(sizeof(share_common_base))
     truncated_dupes[ref] = (share_common_base);
}

void scan(Filesystem.System fs)
{
	foreach(fs->get_dir();; string f)
	{

		// first, let's filter out directory types we want to skip, like bundles.
		
		array x = lower_case(f)/".";
		if((sizeof(x)>1) && exts_to_skip[x[-1]])
		{
		  werror("skipping %s\n", f);
		  continue;
		}
		Stdio.Stat stat = fs->stat(f, 1);
		
		if(!stat)
		{
		  werror("couldn't stat %O\n", combine_path("/" + fs->cwd(), f));
		  exit(1);
		}
		else if(!stat->isdir)
		{
			werror("nonstandard stat for %O: %O\n", combine_path("/" + fs->cwd(), f), stat);
		}
		else if(stat->isdir() && !stat->islnk())
		{
			if(report_dir)
			  report_dir(combine_path("/" + fs->cwd(), f));
			dirs++;
			scan(fs->cd(f));
		}
		else if(stat->isreg() && !stat->islnk())
		{
			if(report_file)
			  report_file(combine_path("/" + fs->cwd(), f));
			files++;
			consider(combine_path("/" + fs->cwd(), f), fs->open(f, "r"));
		}
	}
	
//	werror("have %d suspects.\n", sizeof(suspects));
}

// start by comparing the first 1k of each file.
void consider(string path, Stdio.File f)
{
	string d = f->read(1024);
	string hash = Crypto.MD5()->hash(d);
	
//	werror("%O\n", hash);
	if(suspects[hash])
	{
		suspects[hash] += ({path});
	}
	else if((keys[hash]))
	{
	  suspects[hash] = ({keys[hash], path});
	  m_delete(keys, hash);
	}
	else keys[hash] = path;
}
