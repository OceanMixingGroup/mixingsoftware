% distributes the m_file subdir to the slave and master computer from
% the editing computer....
slave = '\\wymag\data\bottomtrackcomputer\m_files';
master = '\\hecate\data\bottomtrackcomputer\m_files';

dos(['copy ..\m_files\* ' slave]);
dos(['copy ..\m_files\* ' master]);
