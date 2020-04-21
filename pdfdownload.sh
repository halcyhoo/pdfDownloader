#!/bin/bash

get_download_dir () {
  echo -e "What do you want the folder name to be? (Will be created in current directory)"
  read directory

  if [ -d "./$directory" ]
  then
      echo "Directory $directory already exists. Please enter a new folder name"
      get_download_dir
  else
      echo "Thank you! Creating that directory and downloading the pdfs to it."
  fi
}

progressBarWidth=20

progressBar () {

  progress=$(echo "$progressBarWidth/$1*$2" | bc -l)
  fill=$(printf "%.0f\n" $progress)
  if [ $fill -gt $progressBarWidth ]; then
    fill=$progressBarWidth
  fi
  empty=$(($fill-$progressBarWidth))

  percent=$(echo "100/$1*$2" | bc -l)
  percent=$(printf "%0.2f\n" $percent)
  if [ $(echo "$percent>100" | bc) -gt 0 ]; then
    percent="100.00"
  fi

  printf "\r["
  printf "%${fill}s" '' | tr ' ' ▉
  printf "%${empty}s" '' | tr ' ' ░
  printf "] $percent%% - $3"
}

echo ""
echo "Welcome to Halcy's pdf downloader!"
echo ""
echo -e "What is the url that contains the links to the pdfs you want to download?"
read url

echo "Awesome. Looking up the url now: $url"

[[ $url =~ ^.+/ ]]
site_path="${BASH_REMATCH[0]}"

links=( $(curl -s $url | pup 'a attr{href}') )

echo ""
echo "Obtained the links. Filtering for pdfs"
echo ""

pdf_links=()

for i in "${links[@]}"
do
   :
   [[ $i =~ ^.+\.(([pP][dD][fF]))$ ]] && pdf_links+=( $i )
done

echo "Found ${#pdf_links[@]} pdf files"

get_download_dir

mkdir $directory
cd $directory

files_downloaded=0

for i in "${pdf_links[@]}"
do
   :

   progressBar ${#pdf_links[@]} $files_downloaded "Downloading..."

   if [[ "$i" =~ ^http.+ ]]; then
     wget -q $i
   else
     wget -q "$site_path$i"
   fi

   ((files_downloaded=files_downloaded+1))

done

echo ""
echo "You are all set! Have a great day!"
