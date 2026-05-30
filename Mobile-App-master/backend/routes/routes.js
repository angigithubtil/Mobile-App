import bcrypt from "bcryptjs";
import Employee from "../modals/modal.employee.js";
import Shift from "../modals/modal.shift.js";
import { signToken } from "../utils/jwt.js";

const mockDbEnabled = String(process.env.MOCK_DB || "").toLowerCase() === "true";
// Simple in-memory mock users when MOCK_DB=true so login/register works without MongoDB.
const mockUsers = [];
if (mockDbEnabled && mockUsers.length === 0) {
  const salt = bcrypt.genSaltSync(10);
  // seed a couple of users matching the seed script credentials
  mockUsers.push({
    name: "Admin User",
    email: "admin@example.com",
    id: "1001",
    password: bcrypt.hashSync("admin123", salt),
    position: "Administrator",
    shift: "Morning",
    status: "active",
    isAdmin: true,
  });
  mockUsers.push({
    name: "Jane Employee",
    email: "employee@example.com",
    id: "1002",
    password: bcrypt.hashSync("employee123", salt),
    position: "Developer",
    shift: "Evening",
    status: "active",
    isAdmin: false,
  });
}

const sanitizeEmployee = (employee) => {
  if (!employee) return employee;
  const obj = employee.toObject ? employee.toObject() : employee;
  delete obj.password;
  return obj;
};

// Register
async function register(req, res) {
  const {
    name,
    email,
    id,
    password,
    profilePicture,
    phone,
    position,
    shift,
    status,
    isAdmin,
  } = req.body;

  const profilePictureUrl = req.file
    ? `/uploads/${req.file.filename}`
    : profilePicture || undefined;

  const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  if (!name || !email || !id || !password) {
    return res
      .status(400)
      .json({ message: "Name, email, id and password are required." });
  }

  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: "Invalid email address." });
  }

  if (password.length < 6) {
    return res
      .status(400)
      .json({ message: "Password must be at least 6 characters." });
  }

  try {
    if (mockDbEnabled) {
      // Add to in-memory mock users
      const existing = mockUsers.find((u) => u.email === email || u.id === id);
      if (existing) return res.status(400).json({ message: "Email or ID already in use" });
      const salt = bcrypt.genSaltSync(10);
      const hashed = bcrypt.hashSync(password, salt);
      const newUser = { name, email, id, password: hashed, profilePicture: profilePictureUrl, phone, position, shift, status, isAdmin };
      mockUsers.push(newUser);
      const token = signToken({ id: newUser.id, email: newUser.email, isAdmin: newUser.isAdmin });
      const resp = { message: "User created successfully (mock)", employee: { ...newUser, password: undefined }, token };
      return res.status(201).json(resp);
    }
    // Check if email or id already exists
    const existingEmployee = await Employee.findOne({
      $or: [{ email }, { id }],
    });
    if (existingEmployee) {
      return res.status(400).json({ message: "Email or ID already in use" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const employee = new Employee({
      name,
      email,
      id,
      password: hashedPassword,
      profilePicture: profilePictureUrl,
      phone,
      position,
      shift,
      status,
      isAdmin,
    });

    const savedEmployee = await employee.save();
    const employeeObject = savedEmployee.toObject();
    delete employeeObject.password;

    const token = signToken({
      id: employeeObject.id,
      email: employeeObject.email,
      isAdmin: employeeObject.isAdmin,
    });

    return res.status(201).json({
      message: "User created successfully",
      employee: employeeObject,
      token,
    });
  } catch (error) {
    console.error(error);
    return res.status(400).json({ message: "Error creating user", error });
  }
}

async function createEmployee(req, res) {
  const {
    name,
    email,
    id,
    password,
    profilePicture,
    phone,
    position,
    shift,
    status,
    isAdmin,
  } = req.body;

  const profilePictureUrl = req.file
    ? `/uploads/${req.file.filename}`
    : profilePicture || undefined;

  const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  if (!name || !email || !id || !password) {
    return res
      .status(400)
      .json({ message: "Name, email, id and password are required." });
  }

  if (!emailRegex.test(email)) {
    return res.status(400).json({ message: "Invalid email address." });
  }

  if (password.length < 6) {
    return res
      .status(400)
      .json({ message: "Password must be at least 6 characters." });
  }

  try {
    const existingEmployee = await Employee.findOne({
      $or: [{ email }, { id }],
    });
    if (existingEmployee) {
      return res.status(400).json({ message: "Email or ID already in use" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const employee = new Employee({
      name,
      email,
      id,
      password: hashedPassword,
      profilePicture: profilePictureUrl,
      phone,
      position,
      shift,
      status,
      isAdmin,
    });

    const savedEmployee = await employee.save();
    return res.status(201).json({
      message: "Employee created successfully",
      employee: sanitizeEmployee(savedEmployee),
    });
  } catch (error) {
    console.error(error);
    return res.status(400).json({ message: "Error creating employee", error });
  }
}

async function changePassword(req, res) {
  const { id } = req.params;
  const { currentPassword, newPassword } = req.body;

  try {
    // 1. Find the employee by ID
    const employee = await Employee.findOne({ id });
    if (!employee) {
      console.log("Employee not found");
      return res.status(404).json({ message: "Employee not found" });
    }

    // 2. Verify the current password
    const isMatch = await bcrypt.compare(currentPassword, employee.password);
    if (!isMatch) {
      console.log("Incorrect current password");
      return res.status(401).json({ message: "Incorrect current password" });
    }

    // 3. Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // 4. Update and save the new password
    employee.password = hashedPassword;
    await employee.save();

    return res.status(200).json({ message: "Password changed successfully" });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error changing password", error });
  }
}

// Login endpoint: POST /api/login
async function login(req, res) {
  const { email, password } = req.body;

  try {
    if (mockDbEnabled) {
      const m = mockUsers.find((u) => u.email === email);
      if (!m) return res.status(404).json({ message: "User not found" });
      const isMatchM = await bcrypt.compare(password, m.password);
      if (!isMatchM) return res.status(401).json({ message: "Invalid credentials" });
      const tokenM = signToken({ id: m.id, email: m.email, isAdmin: m.isAdmin });
      const userObj = { ...m }; delete userObj.password;
      return res.status(200).json({ message: "Login successful (mock)", employee: userObj, token: tokenM });
    }
    const employee = await Employee.findOne({ email });
    if (!employee) {
      return res.status(404).json({ message: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, employee.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const employeeObject = employee.toObject();
    delete employeeObject.password;
    const token = signToken({
      id: employeeObject.id,
      email: employeeObject.email,
      isAdmin: employeeObject.isAdmin,
    });

    return res.status(200).json({
      message: "Login successful",
      employee: employeeObject,
      token,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Login error", error });
  }
}

//get one employee

async function getOneEmployee(req, res) {
  const { id } = req.params;
  try {
    const employee = await Employee.findOne({ id }).select("-password");
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }
    return res.status(200).json(employee);
  } catch (error) {
    return res.status(500).json({ message: "Error fetching employee", error });
  }
}

//get all employees

async function getAllEmployees(req, res) {
  try {
    const employees = await Employee.find().select("-password");
    return res.status(200).json(employees);
  } catch (error) {
    return res.status(500).json({ message: "Error fetching employees", error });
  }
}

//update employee

async function updateEmployee(req, res) {
  const { id } = req.params;
  const {
    name,
    email,
    password,
    profilePicture,
    phone,
    position,
    shift,
    status,
    isAdmin,
  } = req.body;

  try {
    const updateData = {
      name,
      email,
      profilePicture,
      phone,
      position,
      shift,
      status,
      isAdmin,
    };

    if (password) {
      const salt = await bcrypt.genSalt(10);
      updateData.password = await bcrypt.hash(password, salt);
    }

    const employee = await Employee.findOneAndUpdate({ id }, updateData, {
      new: true,
    }).select("-password");

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json(employee);
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error updating employee", error });
  }
}

//delete employee

async function deleteEmployee(req, res) {
  const { id } = req.params;

  try {
    const employee = await Employee.findOneAndDelete({ id });

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    // Delete all shifts for this employee
    await Shift.deleteMany({ employeeId: Number(id) }); // Make sure types match

    return res
      .status(200)
      .json({ message: "Employee and their shifts deleted successfully" });
  } catch (error) {
    return res.status(500).json({ message: "Error deleting employee", error });
  }
}

//clock in
async function clockin(req, res) {
  const { id } = req.params;
  const { shiftId } = req.body;
  const currentTime = new Date().toLocaleTimeString();
  const date = new Date().toISOString().split("T")[0];

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const shift = await Shift.findOne({ id: shiftId, employeeId: Number(id) });
    if (!shift) {
      return res
        .status(404)
        .json({ message: "Shift not found for this employee" });
    }

    // Check if already clocked in today
    const existingClockIn = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock In",
    );
    if (existingClockIn) {
      return res.status(400).json({ message: "Already clocked in today" });
    }

    // Add clock in record
    shift.attendance.push({
      actionType: "Clock In",
      time: currentTime,
      date: date,
      status: "active",
    });

    // Update employee status
    employee.status = "active";
    await employee.save();
    await shift.save();

    res.status(200).json({ message: "Clock-in successful", shift });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Clock-in failed", error });
  }
}

//clock out
async function clockout(req, res) {
  const { id } = req.params;
  const { shiftId } = req.body;
  const currentTime = new Date().toLocaleTimeString();
  const date = new Date().toISOString().split("T")[0];

  try {
    const employee = await Employee.findOne({ id });
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    const shift = await Shift.findOne({ id: shiftId, employeeId: Number(id) });
    if (!shift) {
      return res
        .status(404)
        .json({ message: "Shift not found for this employee" });
    }

    // Check if clocked in today
    const clockInRecord = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock In",
    );
    if (!clockInRecord) {
      return res.status(400).json({ message: "You haven't clocked in today" });
    }

    // Check if already clocked out
    const existingClockOut = shift.attendance.find(
      (a) => a.date === date && a.actionType === "Clock Out",
    );
    if (existingClockOut) {
      return res.status(400).json({ message: "Already clocked out today" });
    }

    // Add clock out record
    shift.attendance.push({
      actionType: "Clock Out",
      time: currentTime,
      date: date,
      status: "on leave",
    });

    // Update employee status
    employee.status = "on leave";
    await employee.save();
    await shift.save();

    res.status(200).json({ message: "Clock-out successful", shift });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Clock-out failed", error });
  }
}

// assign shift to employee
async function assignShift(req, res) {
  const { date, shiftType, shiftId } = req.body;
  const { id } = req.params;

  try {
    console.log("here are the data sent", date, shiftType, shiftId);

    const existingId = await Shift.findOne({ id: shiftId });
    if (existingId) {
      return res.status(400).json({ message: "ID already in use" });
    }
    const shift = new Shift({
      id: shiftId,
      employeeId: Number(id),
      date,
      shiftType,
    });

    const savedShift = await shift.save();

    return res
      .status(201)
      .json({ message: "Shift assigned successfully", shift: savedShift });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error assigning shift", error });
  }
}

//get assgined shift for single employee

async function getAssignedShift(req, res) {
  const { id } = req.params;

  try {
    const shift = await Shift.find({ employeeId: Number(id) });

    if (!shift) {
      return res.status(404).json({ message: "Shift not found for employee" });
    }

    return res
      .status(200)
      .json({ message: "Shift(s) found successfully", shifts: shift });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error retrieving shift", error });
  }
}

//get all assigned shifts

async function getAllAssignedShifts(req, res) {
  try {
    const shifts = await Shift.find();

    if (!shifts.length) {
      return res.status(404).json({ message: "No assigned shifts found" });
    }

    return res.status(200).json(shifts);
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error retrieving shifts", error });
  }
}

// update shift by ID
async function updateShift(req, res) {
  const { id } = req.params;
  const { date, shiftType, attendance } = req.body;

  try {
    const updateFields = {};
    if (date) updateFields.date = date;
    if (shiftType) updateFields.shiftType = shiftType;

    let updatedShift = await Shift.findOneAndUpdate(
      { id },
      { $set: updateFields },
      { new: true },
    );

    if (attendance && attendance.length > 0) {
      await Shift.updateOne(
        { id },
        { $push: { attendance: { $each: attendance } } },
      );
      updatedShift = await Shift.findOne({ id });
    }

    if (!updatedShift) {
      return res.status(404).json({ message: "Shift not found" });
    }
    console.log(updatedShift);

    return res.status(200).json({
      message: "Shift updated",
      shift: {
        id: updatedShift.id,
        date: updatedShift.date,
        shiftType: updatedShift.shiftType,
        employeeId: updatedShift.employeeId,
        attendance: updatedShift.attendance,
      },
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error updating shift", error });
  }
}

// delete shift by ID
async function deleteShift(req, res) {
  const { id } = req.params;
  console.log(id, typeof id);
  try {
    const deletedShift = await Shift.findOneAndDelete({ id });

    if (!deletedShift) {
      console.log("issue");
      return res.status(404).json({ message: "Shift not found" });
    }

    return res.status(200).json({ message: "Shift deleted successfully" });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Error deleting shift", error });
  }
}

// get single employee with status

async function singleStatus(req, res) {
  const id = req.params.id;
  try {
    const employee = await Employee.findOne({ id }, "name id status");
    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    return res.status(200).json(employee);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employee", error });
  }
}

//get all employees with status

async function getAllEmployeesWithStatus(req, res) {
  try {
    const employees = await Employee.find({}, "name id status");

    if (!employees) {
      return res.status(404).json({ message: "No employees found" });
    }

    return res.status(200).json(employees);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employees", error });
  }
}

//get single employee with attendance
async function singleAttendance(req, res) {
  const { id } = req.params;

  try {
    const employee = await Employee.findOne({ id }, "name id");
    if (!employee) return res.status(404).json({ message: "Employee not found" });

    const shifts = await Shift.find({ employeeId: Number(id) });
    const records = buildFlatAttendanceRecords(shifts, new Map([[id, employee.name]]));
    return res.status(200).json(records);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employee", error });
  }
}
//get all employees with attendance

async function getAllEmployeesWithAttendance(req, res) {
  try {
    const shifts = await Shift.find({ attendance: { $exists: true, $ne: [] } });
    if (!shifts.length) return res.status(200).json([]);

    const employeeIds = [...new Set(shifts.map((s) => s.employeeId))];
    const employees = await Employee.find(
      { id: { $in: employeeIds.map(String) } },
      "id name",
    );
    const nameById = new Map(employees.map((e) => [e.id.toString(), e.name]));
    const records = buildFlatAttendanceRecords(shifts, nameById);
    return res.status(200).json(records);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error retrieving employees", error });
  }
}

function buildFlatAttendanceRecords(shifts, nameByEmployeeId) {
  const byKey = new Map();

  for (const shift of shifts) {
    const employeeId = shift.employeeId?.toString?.() ?? String(shift.employeeId);
    const employeeName = nameByEmployeeId.get(employeeId);

    const attendanceArr = Array.isArray(shift.attendance) ? shift.attendance : [];
    for (const row of attendanceArr) {
      const date = row?.date?.toString?.() ?? "";
      if (!date) continue;

      const key = `${shift.id}:${employeeId}:${date}`;
      const existing = byKey.get(key) ?? {
        id: `${shift.id}:${date}`,
        employeeId,
        employeeName,
        date,
        clockIn: null,
        clockOut: null,
        status: "pending",
        checkIn: null,
      };

      const actionType = row?.actionType;
      const time = row?.time?.toString?.() ?? null;
      if (actionType === "Clock In" && time) {
        existing.clockIn = existing.clockIn ?? time;
        existing.checkIn = existing.checkIn ?? time;
        existing.status = "active";
      }
      if (actionType === "Clock Out" && time) {
        existing.clockOut = existing.clockOut ?? time;
        existing.status = "completed";
      }

      byKey.set(key, existing);
    }
  }

  return [...byKey.values()].sort((a, b) => {
    const d = (b.date ?? "").localeCompare(a.date ?? "");
    if (d !== 0) return d;
    return (b.employeeId ?? "").localeCompare(a.employeeId ?? "");
  });
}

// logout user
async function logout(req, res) {
  // Since there's no token/session mechanism, we'll assume logout is client-handled
  // This function is kept for API completeness
  return res.status(200).json({ message: "Logout successful" });
}

export {
  register,
  changePassword,
  login,
  getAllEmployees,
  getOneEmployee,
  createEmployee,
  updateEmployee,
  deleteEmployee,
  clockin,
  clockout,
  assignShift, // ← Add this line
  getAssignedShift,
  getAllAssignedShifts,
  updateShift,
  deleteShift,
  getAllEmployeesWithStatus,
  getAllEmployeesWithAttendance,
  singleAttendance,
  singleStatus,
  logout, // ← Add this
};
