import path from "path";
import { Router, type IRouter } from "express";
import healthRouter from "./health";

const router: IRouter = Router();

router.use(healthRouter);

// Descarga temporal del proyecto Kuromi
router.get("/download/kuromi", (req, res) => {
  const file = path.resolve("/home/runner/workspace/kuromi.zip");
  res.download(file, "Kuromi-Flutter.zip");
});

export default router;
