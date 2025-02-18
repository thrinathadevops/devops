for file in $(ls images)
do      
        if [[ $file = *.jpeg ]]
                then
                new_nmae=#(echo $file| sed '/home/bob/images')
                mv images/$file images/$new_name
        fi      
done
