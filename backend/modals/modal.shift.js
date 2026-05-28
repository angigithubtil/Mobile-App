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

const shiftSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true },
    employeeId: { type: Number, required: true },
    date: { type: String, required: true },
    shiftType: { type: String, required: true },
    attendance: { type: [attendanceSchema], default: [] },
  },
  { timestamps: true },
);

export default mongoose.model("Shift", shiftSchema);
