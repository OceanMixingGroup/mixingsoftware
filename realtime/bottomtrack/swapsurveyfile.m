cd ../surveydata
[filename, pathname] = uigetfile('*.mat')

if filename
  %unix('del ..\surveydata\survey.mat');
  unix(sprintf('copy %s %s',fullfile(pathname,filename), ...
       fullfile(pathname,'survey.mat')));
end;
cd ../m_files

set_up_survey;
