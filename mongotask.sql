// Connect to MongoDB and create the database
use mongotask;

--  1. Users
db.users.insertMany([
  { _id: ObjectId(), name: "Amar", email: "amar@gmail.com", batch: "FSD-Oct-2020" },
  { _id: ObjectId(), name: "Raja", email: "raja@gmail.com", batch: "FSD-Oct-2020" }
]);

--  2. Mentors
db.mentors.insertMany([
  {
    _id: ObjectId(),
    name: "Meena Iyer",
    email: "meena@example.com",
    mentees: [db.users.findOne({ name: "Amar" })._id, db.users.findOne({ name: "Raja" })._id]
  }
]);

--  3. Codekata
db.codekata.insertMany([
  { user_id: db.users.findOne({ name: "Amar" })._id, problems_solved: 120 },
  { user_id: db.users.findOne({ name: "Raja" })._id, problems_solved: 80 }
]);

--  4. Attendance
db.attendance.insertMany([
  { user_id: db.users.findOne({ name: "Amar" })._id, date: ISODate("2020-10-20"), status: "absent" },
  { user_id: db.users.findOne({ name: "Raja" })._id, date: ISODate("2020-10-22"), status: "present" }
]);

--  5. Topics
db.topics.insertMany([
  { title: "MongoDB Aggregation", date: ISODate("2020-10-18") },
  { title: "React Hooks", date: ISODate("2020-10-25") }
]);

--  6. Tasks
db.tasks.insertMany([
  {
    topic_id: db.topics.findOne({ title: "MongoDB Aggregation" })._id,
    user_id: db.users.findOne({ name: "Amar" })._id,
    title: "Aggregation Practice",
    due_date: ISODate("2020-10-20"),
    submitted: false
  },
  {
    topic_id: db.topics.findOne({ title: "React Hooks" })._id,
    user_id: db.users.findOne({ name: "Raja" })._id,
    title: "Hooks Demo",
    due_date: ISODate("2020-10-26"),
    submitted: true
  }
]);

--  7. Company Drives
db.company_drives.insertMany([
  {
    company_name: "Google",
    drive_date: ISODate("2020-10-25"),
    appeared_users: [db.users.findOne({ name: "Amar" })._id]
  },
  {
    company_name: "Amazon",
    drive_date: ISODate("2020-10-30"),
    appeared_users: [db.users.findOne({ name: "Raja" })._id]
  }
]);


--  1. Topics and tasks taught in October
db.topics.aggregate([
  {
    $match: {
      date: {
        $gte: ISODate("2020-10-01"),
        $lte: ISODate("2020-10-31")
      }
    }
  },
  {
    $lookup: {
      from: "tasks",
      localField: "_id",
      foreignField: "topic_id",
      as: "related_tasks"
    }
  }
]);

// 2. Company drives between 15–31 Oct
db.company_drives.find({
  drive_date: {
    $gte: ISODate("2020-10-15"),
    $lte: ISODate("2020-10-31")
  }
});

--  3. Company drives and students who appeared
db.company_drives.aggregate([
  { $unwind: "$appeared_users" },
  {
    $lookup: {
      from: "users",
      localField: "appeared_users",
      foreignField: "_id",
      as: "student"
    }
  },
  { $unwind: "$student" },
  {
    $project: {
      company_name: 1,
      student_name: "$student.name"
    }
  }
]);

--  4. Problems solved by each user
db.codekata.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "user_id",
      foreignField: "_id",
      as: "user"
    }
  },
  { $unwind: "$user" },
  {
    $project: {
      name: "$user.name",
      problems_solved: 1
    }
  }
]);

--  5. Mentors with more than 15 mentees
db.mentors.aggregate([
  {
    $project: {
      name: 1,
      mentee_count: { $size: "$mentees" }
    }
  },
  {
    $match: {
      mentee_count: { $gt: 15 }
    }
  }
]);

--  6. Users absent and task not submitted between 15–31 Oct
db.attendance.aggregate([
  {
    $match: {
      status: "absent",
      date: {
        $gte: ISODate("2020-10-15"),
        $lte: ISODate("2020-10-31")
      }
    }
  },
  {
    $lookup: {
      from: "tasks",
      let: { userId: "$user_id" },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                { $eq: ["$user_id", "$$userId"] },
                { $eq: ["$submitted", false] },
                { $gte: ["$due_date", ISODate("2020-10-15")] },
                { $lte: ["$due_date", ISODate("2020-10-31")] }
              ]
            }
          }
        }
      ],
      as: "unsubmitted_tasks"
    }
  },
  {
    $match: {
      "unsubmitted_tasks.0": { $exists: true }
    }
  },
  {
    $lookup: {
      from: "users",
      localField: "user_id",
      foreignField: "_id",
      as: "user"
    }
  },
  { $unwind: "$user" },
  {
    $project: {
      name: "$user.name"
    }
  }
]);