import multer from "multer";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    files: 2,
    fileSize: 5 * 1024 * 1024,
  },
});

export const uploadCAFiles = upload.fields([
  { name: "certificate", maxCount: 1 },
  { name: "private_key", maxCount: 1 },
]);

export const mapCAUploadFilesToBody = (req, _res, next) => {
  const certificate = req.files?.certificate?.[0];
  const privateKey = req.files?.private_key?.[0];

  if (certificate) {
    req.body.certificate_base64 = certificate.buffer.toString("base64");
  }

  if (privateKey) {
    req.body.private_key_base64 = privateKey.buffer.toString("base64");
  }

  next();
};
