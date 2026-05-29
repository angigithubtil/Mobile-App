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
    ];

    await Employee.deleteMany({
      $or: [{ email: "admin@example.com" }, { email: "employee@example.com" }],
    });

    await Shift.deleteMany({
      $or: [{ id: "SHIFT-1001" }, { id: "SHIFT-1002" }],
    });

    const created = await Employee.insertMany(sampleEmployees);

    await Shift.insertMany([
      {
        id: "SHIFT-1001",
        employeeId: Number(created[0].id),
        date: "2026-05-27",
        shiftType: "Morning",
      },
      {
        id: "SHIFT-1002",
        employeeId: Number(created[1].id),
        date: "2026-05-27",
        shiftType: "Evening",
      },
    ]);

    console.log("Seed data inserted successfully");
    console.log("Login credentials:");
    console.log("  admin@example.com / admin123");
    console.log("  employee@example.com / employee123");
  } catch (error) {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  } finally {
    await mongoose.disconnect();
  }
};

seed();
