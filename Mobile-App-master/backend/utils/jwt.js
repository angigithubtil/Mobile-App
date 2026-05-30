import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, "../.env") });

const jwtSecret = process.env.JWT_SECRET || "dev-secret";
const jwtExpiresIn = process.env.JWT_EXPIRES_IN || "7d";

export function signToken(payload) {
  return jwt.sign(payload, jwtSecret, { expiresIn: jwtExpiresIn });
}

export function verifyToken(token) {
  return jwt.verify(token, jwtSecret);
}
