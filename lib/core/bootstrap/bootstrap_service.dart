import '../utils/logger.dart';
import 'seed_nodes.dart';

class BootstrapService {
  static List<String> getSeeds() {
    Logger.info("Loading seed nodes from config");
    return SeedNodes.getAll();
  }
}
