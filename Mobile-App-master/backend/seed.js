import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import bcrypt from "bcryptjs";
import mongoose from "mongoose";
import Employee from "./modals/modal.employee.js";
import Shift from "./modals/modal.shift.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, ".env") });

const seed = async () => {
  try {
    const mongoUri =
      process.env.MONGO_URI ||
      "mongodb://127.0.0.1:27017/employee_shift_management";

    await mongoose.connect(mongoUri, {
      serverSelectionTimeoutMS: 5000,
      family: 4,
    });

    console.log("Connected to MongoDB for seeding");

    const salt = await bcrypt.genSalt(10);

    const isoDate = (d) => d.toISOString().slice(0, 10);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const sampleEmployees = [
      {
        name: "Admin User",
        email: "admin@example.com",
        id: "1001",
        password: await bcrypt.hash("admin123", salt),
        position: "Administrator",
        shift: "Morning",
        status: "active",
        isAdmin: true,
      },
      {
        name: "Jane Employee",
        email: "employee@example.com",
        id: "1002",
        password: await bcrypt.hash("employee123", salt),
        position: "Developer",
        shift: "Evening",
        status: "active",
        isAdmin: false,
      },
      {
        name: "Samuel Ops",
        email: "samuel.ops@example.com",
        id: "1003",
        password: await bcrypt.hash("employee123", salt),
        position: "Operations",
        shift: "Morning",
        status: "inactive",
        isAdmin: false,
      },
      {
        name: "Lina Support",
        email: "lina.support@example.com",
        id: "1004",
        password: await bcrypt.hash("employee123", salt),
        position: "Support",
        shift: "Night",
        status: "inactive",
        isAdmin: false,
      },
      {
        name: "Hassan QA",
        email: "hassan.qa@example.com",
        id: "1005",
        password: await bcrypt.hash("employee123", salt),
        position: "QA Engineer",
        shift: "Evening",
        status: "active",
        isAdmin: false,
      },
      {
        name: "Maya Design",
        email: "maya.design@example.com",
        id: "1006",
        password: await bcrypt.hash("employee123", salt),
        position: "Designer",
        shift: "Morning",
        status: "active",
        isAdmin: false,
      },
    ];

    const seedEmails = sampleEmployees.map((e) => e.email);
    const seedIds = sampleEmployees.map((e) => e.id);
    await Employee.deleteMany({ $or: [{ email: { $in: seedEmails } }, { id: { $in: seedIds } }] });
    await Shift.deleteMany({ id: { $regex: /^SHIFT-10(0[1-6])-/ } });

    const created = await Employee.insertMany(sampleEmployees);
    const shiftTypes = ["Morning", "Evening", "Night"];

    const shifts = [];
    // Create 10 days of schedules around today so UI is populated.
    for (let offset = -3; offset <= 6; offset += 1) {
      const date = new Date(today);
      date.setDate(today.getDate() + offset);
      const dateStr = isoDate(date);

      for (const emp of created.filter((e) => !e.isAdmin)) {
        const shiftType = shiftTypes[(Number(emp.id) + offset + 30) % shiftTypes.length];
        const shiftId = `SHIFT-${emp.id}-${dateStr}`;
        const attendance = [];

        // Add some realistic attendance for past days and for today.
        if (offset < 0) {
          attendance.push({ actionType: "Clock In", time: "09:02 AM", date: dateStr, status: "active" });
          attendance.push({ actionType: "Clock Out", time: "05:11 PM", date: dateStr, status: "on leave" });
        } else if (offset === 0 && ["1002", "1005"].includes(emp.id)) {
          attendance.push({ actionType: "Clock In", time: "09:05 AM", date: dateStr, status: "active" });
        }

        shifts.push({
          id: shiftId,
          employeeId: Number(emp.id),
          date: dateStr,
          shiftType,
          attendance,
        });
      }
    }

    await Shift.insertMany(shifts);

    console.log("Seed data inserted successfully");
    console.log("Login credentials:");
    console.log("  admin@example.com / admin123");
    console.log("  employee@example.com / employee123");
    console.log("  samuel.ops@example.com / employee123");
    console.log("  lina.support@example.com / employee123");
    console.log("  hassan.qa@example.com / employee123");
    console.log("  maya.design@example.com / employee123");
  } catch (error) {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
};

seed();
