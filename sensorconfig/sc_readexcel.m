function B=sc_readexcel(fname,SheetName);
% function B=sc_readexcel(fname,SheetName);
% Open the spreadsheet in fname and read teh data from SheetName.
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:52 $ $Author: aperlin $	
% J. Klymak, Aug 2002
  
  
% First open an Excel Server
Excel = actxserver('Excel.Application');
set(Excel, 'Visible', 0);

% Open the workbook
Workbooks = get(Excel,'Workbooks');
Workbook = Open(Workbooks,fname);
Sheets = Excel.ActiveWorkBook.Sheets;
for i=1:get(Sheets,'Count');
  % Make the second sheet active
  sheet = get(Sheets, 'Item', i);
  get(sheet,'Name');
  if strcmp(get(sheet,'Name'),SheetName)
    % Get back a range.  It will be a cell array, since the cell range can
    % contain different types of data.
    Range = get(sheet, 'UsedRange');
    B = Range.value;
    break
  end;
end;

% Quit Excel
invoke(Excel, 'Quit');

