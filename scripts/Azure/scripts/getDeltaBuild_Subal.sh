#!/bin/bash

################################################################################
echo 'Starting Salesforce Prepare Build Job'
echo 'Command Name = ' $0
echo 'Start Date   = ' $1
echo 'End Date     = ' $2
echo 'Branch Name  = ' $3
#echo 'Production Build         = ' $
echo 'Build Number =' $4
echo 'Build Prefix =' $5
################################################################################
Start_Date=$1
End_Date=$2
echo 'start_date' $Start_Date
echo 'end_date' $End_Date

#LOG_PATH=/var/lib/jenkins/sf-build-job/git/
LOG_PATH_logs=$AGENT_BUILDDIRECTORY/logs
#JENKINS_WS_PATH=/var/lib/jenkins/jobs/MBOLT-ContinuousDelivery-GIT/workspace/sfdc
JENKINS_WS_PATH_sfdc=$AGENT_BUILDDIRECTORY/sfdc
#REPO_LOCAL_COPY_PATH=/var/lib/jenkins/sf-build-job/git/sf_dev_ops
REPO_LOCAL_COPY_PATH=$AGENT_BUILDDIRECTORY/s
#PKG_PATH=/var/lib/jenkins/sf-build-job/git/build/build-$4/
#PKG_PATH=$AGENT_BUILDDIRECTORY/builds/build-$4/

mkdir -p $LOG_PATH_logs
mkdir -p $JENKINS_WS_PATH_sfdc
#mkdir -p $PKG_PATH



cd $REPO_LOCAL_COPY_PATH

if [[ `git branch --list $3`  ]];then
	echo "Branch " $3 "exists !"
else
	echo "Branch " $3 "does not exists !"
	#exit;

fi

cp /dev/null $LOG_PATH_logs/out.log
chmod 777 $LOG_PATH_logs/out.log
cp /dev/null $LOG_PATH_logs/main.log
chmod 777 $LOG_PATH_logs/main.log
cp /dev/null $LOG_PATH_logs/mainprocessed.log
chmod 777 $LOG_PATH_logs/mainprocessed.log

#rm -rf $JENKINS_WS_PATH_sfdc/src
#echo "Cleaned up Workspace looks like below..."
#ls -alR $JENKINS_WS_PATH_sfdc/src

cd $REPO_LOCAL_COPY_PATH
#git pull
git checkout $3
git log --since $Start_Date --until $End_Date --name-only --pretty=format:"%H$" >> $LOG_PATH_logs/main.log

index=0;
lines=`cat $LOG_PATH_logs/main.log`
IFS=$'\n'
        for line in $lines
        do
                echo '>> '$line
                if [[ $line = *\$ ]]; then
                        echo "pattern" $line
                        rev=`echo $line | cut -d '$' -f1`
                        echo "rev =" $rev
                else
                        filex=$(basename "$line")
                        echo "filex = "$filex
                        if [[ $filex = *.* ]] ; then
                               # echo "hello"
                                filenameArray[$index]=$index" & "$line" & "$rev
                        else
                                filenameArray[$index]=$index" & "$line" & "$rev
                        fi
                        ((index++))
                 fi
        done
echo ${#filenameArray[@]}
echo ${filenameArray[@]}

num=${#filenameArray[@]}
echo "num = " $num

for (( i=0; i<=num+1; i++ ))
do
        if [ "${#filenameArray[i]}" -eq 0 ]; then
                echo "i = " $i position has no elements
                continue
        fi

        echo ${filenameArray[i]} >> $LOG_PATH_logs/mainprocessed.log
done


cat $LOG_PATH_logs/mainprocessed.log | awk -F"&" '{print$1"@"$2"@"$3}' | sort -n | awk -F " " '!arr[$3]++' >> $LOG_PATH_logs/out.log

#mkdir -p $JENKINS_WS_PATH_sfdc/src/

cat $LOG_PATH_logs/out.log | while read line
do
  file=$(echo $line | awk -F"@" '{printf" "$2" "}'|xargs)
  version=$(echo $line | awk -F"@" '{printf" "$3" "}'|xargs)
  echo "Processing file " $file   " Version:=>" $version

  fileName=$(basename "$file")
  echo "fileName = "$fileName
  if [[ $fileName = *.* ]] ; then
        dir=$(dirname "$file")
        echo 'Current dirtory path: ' $dir
        mkdir -p $JENKINS_WS_PATH_sfdc/src/"$dir"        
        exportDir=/src/$dir
        echo 'export dir:' $exportDir
  else
  #     echo "Its not file..."
        mkdir -p $JENKINS_WS_PATH_sfdc/src/"$file"
        exportDir=/src/$file
        echo 'only file: ' $file
        echo '@file export dir:' $exportDir
  fi


  if [[ $file == *".cls"* ]];then
         cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
     if [[ $file != *".cls-meta.xml"* ]];then
        #echo "Getting the Meta XML"
        metaXML=$(echo $file |cut -d '@' -f1 |sed 's/\.cls/.cls-meta.xml/')
        echo $metaXML
        cp $REPO_LOCAL_COPY_PATH/$metaXML $JENKINS_WS_PATH_sfdc/$exportDir
     fi
  fi

  # component File Filter
  if [[ $file == *".component"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
     if [[ $file != *".component-meta.xml"* ]];then
        metaXML=$(echo $file |cut -d '#' -f1 |sed 's/\.component/.component-meta.xml/')
        cp $REPO_LOCAL_COPY_PATH/$metaXML $JENKINS_WS_PATH_sfdc/$exportDir
     fi
  fi

  # Email File Filter
  if [[ $file == *".email"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
     if [[ $file != *".email-meta.xml"* ]];then
        metaXML=$(echo $file |cut -d '#' -f1 |sed 's/\.email/.email-meta.xml/')
        cp $REPO_LOCAL_COPY_PATH/$metaXML $JENKINS_WS_PATH_sfdc/$exportDir
     fi
  fi

  # Page File Filter
  if [[ $file == *".page"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
     if [[ $file != *".page-meta.xml"* ]];then
        metaXML=$(echo $file |cut -d '#' -f1 |sed 's/\.page/.page-meta.xml/')
        cp $REPO_LOCAL_COPY_PATH/$metaXML $JENKINS_WS_PATH_sfdc/$exportDir
     fi
  fi

  # resource File Filter
  if [[ $file == *".resource"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
     if [[ $file != *".resource-meta.xml"* ]];then
        metaXML=$(echo $file |cut -d '#' -f1 |sed 's/\.resource/.resource-meta.xml/')
        cp $REPO_LOCAL_COPY_PATH/$metaXML $JENKINS_WS_PATH_sfdc/$exportDir
     fi
  fi

   # trigger File Filter
  if [[ $file == *".trigger"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
     if [[ $file != *".trigger-meta.xml"* ]];then
        metaXML=$(echo $file |cut -d '#' -f1 |sed 's/\.trigger/.trigger-meta.xml/')
        cp $REPO_LOCAL_COPY_PATH/$metaXML $JENKINS_WS_PATH_sfdc/$exportDir
     fi
  fi

  # analyticSnapshots File Filter
  if [[ $file == *".snapshots"* ]];then
        cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # applications File Filter
  if [[ $file == *".app"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # dashboards File Filter
  if [[ $file == *".dashboard"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # datacategorygroups File Filter
  if [[ $file == *".datacategorygroup"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # flows File Filter
  if [[ $file == *".flow"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  
   # homePageLayouts File Filter
  if [[ $file == *".homePageLayout"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # labels File Filter
  if [[ $file == *".labels"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # layouts File Filter
  if [[ $file == *".layout"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # object File Filter
  if [[ $file == *".object"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # objectTranslations File Filter
 # if [[ $file == *".objectTranslation"* ]];then
 # cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
 #
 # fi

  # portals File Filter
  if [[ $file == *".portal"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # profiles File Filter
  if [[ $file == *"profile"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

   # remoteSiteSettings File Filter
  if [[ $file == *".remoteSite"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # reports File Filter
  if [[ $file == *".report"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # reportTypes File Filter
  if [[ $file == *".reportType"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # sites File Filter
  if [[ $file == *".site"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  # tabs File Filter
  if [[ $file == *".tab"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

 # # translations File Filter
 # if [[ $file == *".translation"* ]];then
 #    cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir
 #
 # fi

  # weblinks File Filter
  if [[ $file == *".weblink"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi

  
   # workflows File Filter
  if [[ $file == *".workflow"* ]];then
     cp $REPO_LOCAL_COPY_PATH/$file $JENKINS_WS_PATH_sfdc/$exportDir

  fi



done

branchName=$(echo $3 | sed 's/\/\...//g')
echo "Branch Name:" $branchName


cp $REPO_LOCAL_COPY_PATH/ant-salesforce.jar $JENKINS_WS_PATH_sfdc/
#cp $REPO_LOCAL_COPY_PATH/deployable-package.xml $JENKINS_WS_PATH_sfdc/src/
cp $REPO_LOCAL_COPY_PATH/src/package.xml $JENKINS_WS_PATH_sfdc/src/
cp $REPO_LOCAL_COPY_PATH/build.xml $JENKINS_WS_PATH_sfdc/
cp $REPO_LOCAL_COPY_PATH/build.properties $JENKINS_WS_PATH_sfdc/
cd $JENKINS_WS_PATH_sfdc/src/src
mv * ../
rm -rf $JENKINS_WS_PATH_sfdc/src/src

###################################################################################
#cd $PKG_PATH/
#cp -r $JENKINS_WS_PATH_sfdc/src .
#cd $PKG_PATH/
###################################################################################

echo 'List of final package:'
ls -l $JENKINS_WS_PATH_sfdc
echo 'src folder content:'
ls -l $JENKINS_WS_PATH_sfdc/src

#echo 'Main log:'
#cat $LOG_PATH_logs/main.log
#echo 'Process log:'
#cat $LOG_PATH_logs/mainprocessed.log
#echo 'out log:'
#cat $LOG_PATH_logs/out.log
#echo 'PKG_Path'
#ls -l $PKG_PATH/src
#buildZip=$(echo salesforce-build-$4.zip)
#zip -r $buildZip *