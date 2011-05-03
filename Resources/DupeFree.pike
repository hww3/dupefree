import Public.ObjectiveC;
object NSApp;

int main(int argc, array argv)
{
  string sparklePath = combine_path(getcwd(), "../Frameworks/Sparkle.framework");
  int res = Public.ObjectiveC.load_bundle(sparklePath);
  werror("Loaded Sparkle: %O\n", (res==0)?"Okay":"Not Okay");
  NSApp = Cocoa.NSApplication.sharedApplication();
  add_constant("NSApp", NSApp);
//  master()->add_module_path("modules");
//  NSApp->setDelegate_(this);
  NSApp->activateIgnoringOtherApps_(1);
  add_backend_to_runloop(Pike.DefaultBackend, 0.01);
werror("path: %O\n", master()->pike_module_path);
  return AppKit()->NSApplicationMain(argc, argv);
  
//return 0;
}

