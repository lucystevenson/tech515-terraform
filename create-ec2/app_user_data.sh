#!/bin/bash
echo "Running user data..."
cd /home/ubuntu/tech515-sparta-app/app

# Save DB_HOST permanently so the app + PM2 can access it
echo "export DB_HOST=mongodb://${aws_instance.db_instance.private_ip}:27017/posts" >> /etc/profile
echo "export DB_HOST=mongodb://${aws_instance.db_instance.private_ip}:27017/posts" >> /home/ubuntu/.bashrc

export DB_HOST="mongodb://${aws_instance.db_instance.private_ip}:27017/posts"
echo "DB_HOST is: $DB_HOST"
pm2 restart app.js --update-env
echo "User data done!"