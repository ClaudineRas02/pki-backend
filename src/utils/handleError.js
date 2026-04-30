export const handleError = (error, res) => {
  const status = error.status || 500;
  res.status(status).json({
    message: error.message || "Une erreur est survenue.",
  });
};
