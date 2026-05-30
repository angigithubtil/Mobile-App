import express from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";
import { requireAdmin, requireSelfOrAdmin } from "../middleware/roles.js";
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
router.post(
  "/employees",
  requireAdmin,
  upload.single("profilePicture"),
  createEmployee,
);
router.get("/employees", requireAdmin, getAllEmployees);
router.get("/employees/:id", requireSelfOrAdmin("id"), getOneEmployee);
router.put("/employees/:id", requireSelfOrAdmin("id"), updateEmployee);
router.delete("/employees/:id", requireAdmin, deleteEmployee);
router.put("/updateEmployee/:id", requireSelfOrAdmin("id"), updateEmployee);
router.delete("/deleteEmployee/:id", requireAdmin, deleteEmployee);
router.post("/clockin/:id", requireSelfOrAdmin("id"), clockin);
router.post("/clockout/:id", requireSelfOrAdmin("id"), clockout);
router.post("/assignShift/:id", requireAdmin, assignShift);
router.get("/assignedShift", requireAdmin, getAllAssignedShifts);
router.get("/assignedShift/:id", requireSelfOrAdmin("id"), getAssignedShift);
router.put("/updateShift/:id", requireAdmin, updateShift);
router.delete("/shifts/:id", requireAdmin, deleteShift);
router.get("/status/:id", requireSelfOrAdmin("id"), singleStatus);
router.get("/status", requireAdmin, getAllEmployeesWithStatus);
router.get("/attendance/:id", requireSelfOrAdmin("id"), singleAttendance);
router.get("/attendance", requireAdmin, getAllEmployeesWithAttendance);
router.post("/logout", logout);

export default router;
