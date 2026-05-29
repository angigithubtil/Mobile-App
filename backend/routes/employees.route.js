import express from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";
import {
  register,
  login,
  createEmployee,
  getAllEmployees,
  getOneEmployee,
  updateEmployee,
  deleteEmployee,
  clockin,
  clockout,
  assignShift,
  getAssignedShift,
  getAllAssignedShifts,
  updateShift,
  deleteShift,
  getAllEmployeesWithStatus,
  getAllEmployeesWithAttendance,
  singleAttendance,
  singleStatus,
  logout,
} from "./routes.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const upload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, path.join(__dirname, "../uploads"));
    },
    filename: (req, file, cb) => {
      const timestamp = Date.now();
      const safeName = file.originalname.replace(/[^a-z0-9.\-\_\.]/gi, "_");
      cb(null, `${timestamp}-${safeName}`);
    },
  }),
  limits: { fileSize: 3 * 1024 * 1024 },
});

const router = express.Router();

router.post("/register", upload.single("profilePicture"), register);
router.post("/login", login);
router.post("/employees", upload.single("profilePicture"), createEmployee);
router.get("/employees", getAllEmployees);
router.get("/employees/:id", getOneEmployee);
router.put("/employees/:id", updateEmployee);
router.delete("/employees/:id", deleteEmployee);
router.put("/updateEmployee/:id", updateEmployee);
router.delete("/deleteEmployee/:id", deleteEmployee);
router.post("/clockin/:id", clockin);
router.post("/clockout/:id", clockout);
router.post("/assignShift/:id", assignShift);
router.get("/assignedShift", getAllAssignedShifts);
router.get("/assignedShift/:id", getAssignedShift);
router.put("/updateShift/:id", updateShift);
router.delete("/shifts/:id", deleteShift);
router.get("/status/:id", singleStatus);
router.get("/status", getAllEmployeesWithStatus);
router.get("/attendance/:id", singleAttendance);
router.get("/attendance", getAllEmployeesWithAttendance);
router.post("/logout", logout);

export default router;
