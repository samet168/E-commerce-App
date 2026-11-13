import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/branch_model.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _api = ApiClient();

  // Get Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _api.get(ApiConstants.categories, requiresAuth: false);
      if (response is List) {
        return response.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _fallbackCategories;
    } catch (_) {
      return _fallbackCategories;
    }
  }

  // Get Branches
  Future<List<Branch>> getBranches() async {
    try {
      final response = await _api.get(ApiConstants.branches, requiresAuth: false);
      if (response is List) {
        return response.map((json) => Branch.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _fallbackBranches;
    } catch (_) {
      return _fallbackBranches;
    }
  }

  // Get Products
  Future<List<Product>> getProducts({String? category, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _api.get(
        ApiConstants.products,
        queryParams: queryParams,
        requiresAuth: false,
      );

      if (response is List) {
        return response.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static final List<Category> _fallbackCategories = [
    Category(name: 'All', nameKhmer: 'ទាំងអស់', iconName: 'Layers'),
    Category(name: 'Burgers', nameKhmer: 'ប៊ឺហ្គឺ', iconName: 'Utensils'),
    Category(name: 'Pizza', nameKhmer: 'ភីហ្សា', iconName: 'Pizza'),
    Category(name: 'Asian Food', nameKhmer: 'ម្ហូបអាស៊ី', iconName: 'Soup'),
    Category(name: 'Coffee & Drinks', nameKhmer: 'កាហ្វេ និងភេសជ្ជៈ', iconName: 'Coffee'),
    Category(name: 'Desserts', nameKhmer: 'បង្អែម', iconName: 'Cake'),
  ];

  static final List<Branch> _fallbackBranches = [
    Branch(
      id: 1,
      code: 'TK-01',
      name: 'Toul Kork Flagship Store',
      address: 'Street 315, Sangkat Boeng Kak 1, Khan Toul Kork, Phnom Penh',
      phone: '+855 23 888 101',
    ),
    Branch(
      id: 2,
      code: 'BKK-01',
      name: 'BKK1 Royal Branch',
      address: 'Street 51, Sangkat Boeng Keng Kang 1, Khan Chamkarmon, Phnom Penh',
      phone: '+855 23 888 102',
    ),
    Branch(
      id: 3,
      code: 'SS-01',
      name: 'Sen Sok Mega Branch',
      address: 'Hanoi Blvd, Sangkat Phnom Penh Thmey, Khan Sen Sok, Phnom Penh',
      phone: '+855 23 888 103',
    ),
  ];
}
