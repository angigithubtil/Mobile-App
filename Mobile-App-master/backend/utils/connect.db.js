import mongoose from "mongoose";
import dns from "dns";

const connectDB = async () => {
  const primaryUri = process.env.MONGO_URI?.trim();
  const fallbackUri =
    process.env.MONGO_URI_FALLBACK?.trim() || "mongodb://127.0.0.1:27017/employee_shift_management";
  const mockDbEnabled = String(process.env.MOCK_DB || "").toLowerCase() === "true";
  const isProd = String(process.env.NODE_ENV || "").toLowerCase() === "production";

  if (mockDbEnabled) {
    console.warn("MOCK_DB=true detected. Skipping MongoDB connection.");
    return;
  }

  try {
    // Configure DNS to use Google's DNS servers
    dns.setServers(["8.8.8.8", "8.8.4.4"]);

    const options = {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      family: 4,
      maxPoolSize: 10,
      minPoolSize: 5,
      retryWrites: true,
      retryReads: true
    };

    if (!primaryUri) {
      throw new Error("MONGO_URI is missing");
    }

    const conn = await mongoose.connect(primaryUri, options);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (err) {
    console.error("Primary MongoDB connection failed:", err.message);
    try {
      const conn = await mongoose.connect(fallbackUri, {
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
        family: 4,
        maxPoolSize: 10,
        minPoolSize: 1,
        retryWrites: true,
        retryReads: true,
      });
      console.log(`Fallback MongoDB connected: ${conn.connection.host}`);
    } catch (fallbackErr) {
      if (mockDbEnabled || !isProd) {
        console.warn("Fallback connection failed, continuing in mock mode for local testing.");
        return;
      }
      throw fallbackErr;
    }
  }
};

export default connectDB;
