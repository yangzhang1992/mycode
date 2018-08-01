此脚本会遍历每个库，删除每个库.git以外的所有文件


从manifest取git库的path路径： 
 awk '/path/{split($0,a,"(=\")|(\" )");print a[4]}' manifest.xml >> delete_except_git.list