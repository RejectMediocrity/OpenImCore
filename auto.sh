#! /bin/sh

git_commit_des="升级SDK"

echo "\n ---- 开始升级SDK ---- \n"

echo "\n ---- 正在获取podspec文件 ---- \n"

file_path=""
file_name=""
file_extension="podspec"
directory="$(pwd)"

function getFileAtDirectory(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ]
        then 
            getFileAtDirectory $dir_or_file
        else
            file_extension=${dir_or_file##*.}
            if [[ $file_extension == $2 ]];
            then
            	echo "\n ---- $dir_or_file 是 $2 文件 ---- "
            	file_path=$dir_or_file
            	file_name=$element
            fi
        fi  
    done
}
getFileAtDirectory $directory $file_extension

echo "\n ---- file_path: ${file_path} ---- \n"
echo "\n ---- file_name: ${file_name} ---- \n"

echo "\n ---- 开始读取podspec文件内容 ---- \n"
pod_file_name=${file_name}
search_str="s.version"
podspec_version=""
my_file="${pod_file_name}"

while read my_line
do
	result=$(echo ${my_line} | grep "^${search_str}")
	if [[ "$result" != "" ]]
	then
   		echo "\n ${my_line} 包含 ${search_str}"
		array=(${result// / })
		count=${#array[@]}
		version=${array[count - 1]}
		version=${version//\'/}
		podspec_version=$version
	fi

done < $my_file
echo "\n ---- podspec_version: ${podspec_version} ---- \n"

pod_spec_name=${file_name}
pod_spec_version=${podspec_version}

echo "\n ---- ${pod_spec_name} ${pod_spec_version} ---- \n"

echo "\n ----- 执行 git 本地提交代码操作 ----- \n"
git add .
git status
git commit -m ${git_commit_des}
git tag ${pod_spec_version}
git push origin main --tags

echo "\n ---- pod正在校验 ---- \n"
pod spec lint ${pod_spec_name} --allow-warnings --verbose

echo "\n ---- pod正在发布 ---- \n"
pod repo push MindImCoreSpec ${pod_spec_name} --allow-warnings
pod repo update

echo "\n ---- 升级SDK成功 ---- \n"



