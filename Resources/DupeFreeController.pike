import Public.ObjectiveC;

//inherit Cocoa.NSObject;

Cocoa.NSApplication app;
object Spinner;

void create()
{
//  ::create();
}

void addFolder_(object a)
{
  object openPanel = Cocoa.NSOpenPanel.openPanel();
  openPanel->setCanChooseFiles_(0);
  openPanel->setCanChooseDirectories_(1);

  if(!openPanel->runModal()) return;

  mixed files = openPanel->filenames();
/*
  if(sizeof(files))
    foreach(files;;mixed file)
    {
        werror("fILE:%O\n",(string)( file->__objc_classname));
      jobinfo = Driver->loadRibbon((string)file);
      set_job_info();
    }
  CasterToggleButton->setEnabled_(1);
  JumpToLineItem->setEnabled_(1);
  app->mainMenu()->update();
*/
}
