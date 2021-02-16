#!/bin/bash 
until mongo --host $CA_MONGO_HOST --eval "print(\"Connected!\")" > /dev/null
do
    sleep 2
done
# this won't do anything if collections already exist
mongo --quiet --host $CA_MONGO_HOST camic config/mongo_collections.js
mongo --quiet --host $CA_MONGO_HOST camic config/mongo_idx.js
echo "indexes created (note that some failures will not show up here)"
mongo --quiet --host $CA_MONGO_HOST camic config/add_users.js
echo "users created"
mongo --quiet --host $CA_MONGO_HOST camic config/default_data.js
# uncommenting this could be useful for testing
# mongo --host ca-mongo camic2 /config/test_seed.js
echo "defaults added"
