import mongoose from "mongoose";

const attendanceSchema = new mongoose.Schema(
  {
    actionType: { type: String, required: true },
    time: { type: String, required: true },
    date: { type: String, required: true },
    status: { type: String, required: true },
  },
  { _id: false },
);

const employeeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    id: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    profilePicture: { type: String },
    phone: { type: String },
    address: { type: String },
    position: { type: String },
    shift: { type: String },
    status: { type: String, default: "inactive" },
    isAdmin: { type: Boolean, default: false },
    attendance: { type: [attendanceSchema], default: [] },
  },
  { timestamps: true },
);

export default mongoose.model("Employee", employeeSchema);
