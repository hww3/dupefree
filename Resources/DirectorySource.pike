import Public.ObjectiveC;

//inherit Cocoa.NSObject;

object records = Cocoa.NSMutableArray.arrayWithCapacity_(10);

void create()
{
//	::create();
}

string tableView_objectValueForTableColumn_row_(object view, object column, object row)
{
	return "foo";
	object theRecord = records->objectAtIndex_(row);
	//return theRecord;
}

void tableView_setObjectValue_forTableColumn_row_(object view, object value, object column, object row)
{
  records->replaceObjectAtIndex_withObject_(row, value);
}

object numberOfRowsInTableView_(object view)
{
  return records->count();	
}

void addRecord(string directory)
{
	records->addObject_(directory);
}

void removeRecord(int i)
{
	records->removeObjectAtIndex_(i);
}