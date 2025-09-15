 MongoDB Task


This project sets up a MongoDB database for the Zen Class Programme, including collections for users, mentors, codekata progress, attendance, topics, tasks, and company drives. It also includes aggregation queries for analytics and reporting.

Collections Overview


1. users
   - name
   - email
   - batch

2. mentors
   - name
   - email
   - mentees (array of user IDs)

3. codekata
   - user_id
   - problems_solved

4. attendance
   - user_id
   - date
   - status ("present" or "absent")

5. topics
   - title
   - date

6. tasks
   - topic_id
   - user_id
   - title
   - due_date
   - submitted (true/false)

7. company_drives
   - company_name
   - drive_date
   - appeared_users (array of user IDs)

Aggregation Queries
-------------------

1. Topics and tasks taught in October 2020:
   - Match topics with date in October
   - Lookup related tasks

2. Company drives between 15–31 Oct 2020:
   - Filter company_drives by date range

3. Company drives and students who appeared:
   - Unwind appeared_users
   - Lookup user names

4. Problems solved by each user:
   - Join codekata with users
   - Project name and problems_solved

5. Mentors with more than 15 mentees:
   - Project mentee count
   - Filter where count > 15

6. Users absent and task not submitted between 15–31 Oct 2020:
   - Match attendance with status "absent" and date range
   - Lookup tasks with matching user_id, not submitted, and due in date range
   - Filter users with matching tasks

Usage Instructions
------------------

1. Open mongosh and connect to your MongoDB instance.
2. Paste the shell script to create collections and insert sample data.
3. Run the aggregation queries to test functionality.

License
-------

This project is open-source and free to use for educational or commercial purposes.