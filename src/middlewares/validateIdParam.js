import { createHttpError } from "../utils/httpError.js";

export const validateIdParam = (paramName) => {
  return (req, _res, next) => {
    const value = Number(req.params[paramName]);

    if (!Number.isInteger(value) || value <= 0) {
      return next(createHttpError(400, `Le parametre ${paramName} doit etre un entier positif.`));
    }

    req.params[paramName] = value;
    next();
  };
};
