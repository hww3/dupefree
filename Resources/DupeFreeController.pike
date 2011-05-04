import Public.ObjectiveC;

//inherit Cocoa.NSObject;

Cocoa.NSApplication app;
object Spinner;

object directoryList;
object directorySource;
object addButton;
object removeButton;
object runButton;
object window;

void create()
{
//  ::create();
  directorySource = (object)("DirectorySource");
}

void awakeFromNib()
{
	werror(
		"!!!!\n!!!!!\n!!!!!\n");
	directoryList->setDataSource_(directorySource);
}

void _finishedMakingConnections()
{
	werror(
		"!!!!\n!!!!! %O\n!!!!!\n", directorySource);	
	directoryList->setDataSource_(directorySource);
}
void addFolder_(object a)
{	
  object openPanel = Cocoa.NSOpenPanel.openPanel();
  openPanel->setCanChooseFiles_(0);
  openPanel->setCanChooseDirectories_(1);

  if(!openPanel->runModal()) return;

  mixed files = openPanel->filenames();

  if(sizeof(files))
    foreach(files;;mixed file)
    {
        werror("fILE:%O\n",(string)( file->__objc_classname));
        addDirectory(file);
    }
/*
  CasterToggleButton->setEnabled_(1);
  JumpToLineItem->setEnabled_(1);
  app->mainMenu()->update();
*/
}

void addDirectory(object dir)
{
	directorySource->addRecord(dir);
	directoryList->reloadData();
}

void removeFolder_(object a)
{
}

void runScan_(object a)
{	
}

void selectFolder_(object a)
{
}