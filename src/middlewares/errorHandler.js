import { handleError } from "../utils/handleError.js";

export const errorHandler = (error, _req, res, _next) => {
  handleError(error, res);
};
