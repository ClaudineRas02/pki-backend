import { handleError } from "../utils/handleError.js";
import { listArtifacts } from "../services/artifactService.js";

export const listArtifactsController = async (_req, res) => {
  try {
    const artifacts = await listArtifacts();
    res.status(200).json(artifacts);
  } catch (error) {
    handleError(error, res);
  }
};
