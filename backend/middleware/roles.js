export function requireAdmin(req, res, next) {
  if (req.user?.isAdmin === true) return next();
  return res.status(403).json({ message: "Admin access required" });
}

export function requireSelfOrAdmin(paramName = "id") {
  return (req, res, next) => {
    if (req.user?.isAdmin === true) return next();
    const requested = req.params?.[paramName]?.toString();
    const me = req.user?.id?.toString();
    if (requested && me && requested === me) return next();
    return res.status(403).json({ message: "Access denied" });
  };
}

