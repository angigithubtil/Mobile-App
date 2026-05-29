import express from "express";
import dotenv from "dotenv";
import connectDB from "./utils/connect.db.js";
import employeeRoutes from "./routes/employees.route.js";
import authMiddleware from "./middleware/auth.js";
import cors from "cors";
import mongoose from "mongoose";
import { fileURLToPath } from "url";
import path from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.join(__dirname, ".env") });
const app = express();

// Middleware to log incoming API requests with status and latency.
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const elapsedMs = Date.now() - start;
    const ok = res.statusCode >= 200 && res.statusCode < 300;
    console.log(
      `${req.method} ${req.url} ${res.statusCode} ${ok ? "OK" : "ERR"} ${elapsedMs}ms`,
    );
  });
  next();
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/api", (req, res, next) => {
  if (mongoose.connection.readyState !== 1) {
    return res.status(503).json({
      message:
        "Database not connected. Run MongoDB or set MOCK_DB=true for non-DB route testing.",
    });
  }
  next();
});
app.use("/api", authMiddleware);
app.use("/api", employeeRoutes);

if (process.env.NODE_ENV !== "test") {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
    connectDB().catch((err) => {
      console.error("DB initialization failed:", err.message);
    });
  });
}

export default app;
