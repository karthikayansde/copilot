import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/knowledge_source_model.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class KnowledgeSourceController extends GetxController {
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var knowledgeSources = <KnowledgeSourceModel>[].obs;
  var selectedIds = <String>{}.obs; // Track selected contentIds
  
  // Filter states
  final filterColumns = [
    'Content ID',
    'Document Content',
    'Source File',
    'Category',
    'Status',
    'Role'
  ];
  var selectedFilterColumn = 'Content ID'.obs;
  var searchQuery = ''.obs;
  
  // Dialog data lists
  final categories = [
    'Marketing',
    'AI Features',
    'Data Quality',
    'Social Media',
    'Project Plan',
    'Data Governance',
    'ETL',
    'Inventory Optimization',
    'DQGS Features',
    'SAP',
    'ICF',
    'User Manual',
    'Playbook',
    'PiLog Overview',
    'PM Data',
    'Other'
  ];
  final statuses = ['COMPLETED', 'PENDING'];
  final inputTypes = ['File', 'Plain Text'];
  
  // Add New Entry Form States
  var selectedInputType = 'File'.obs;
  var uploadedFiles = <PlatformFile>[].obs;
  var selectedAddCategory = ''.obs;
  var isTOCAvailable = 'No'.obs; // Yes, No, NA
  var tocHeadings = ''.obs;
  var plainTextContent = ''.obs;

  void resetAddForm() {
    selectedInputType.value = 'File';
    uploadedFiles.clear();
    selectedAddCategory.value = '';
    isTOCAvailable.value = 'No';
    tocHeadings.value = '';
    plainTextContent.value = '';
  }

  List<KnowledgeSourceModel> get filteredKnowledgeSources {
    if (searchQuery.value.isEmpty) {
      return knowledgeSources;
    }
    return knowledgeSources.where((item) {
      String valueToSearch = '';
      switch (selectedFilterColumn.value) {
        case 'Content ID':
          valueToSearch = item.contentId ?? '';
          break;
        case 'Document Content':
          valueToSearch = item.documentContent ?? '';
          break;
        case 'Source File':
          valueToSearch = item.sourceFile ?? '';
          break;
        case 'Category':
          valueToSearch = item.category ?? '';
          break;
        case 'Status':
          valueToSearch = item.status ?? '';
          break;
        case 'Role':
          valueToSearch = item.role ?? '';
          break;
      }
      return valueToSearch.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  bool isSelected(String id) => selectedIds.contains(id);

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  bool hasSelection({String? message}) {
    if (selectedIds.isEmpty) {
      Get.snackbar(
        'Warning',
        message ?? 'Please select at least one item.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  bool hasExactlyOneSelection({String? message}) {
    if (selectedIds.length != 1) {
      Get.snackbar(
        'Warning',
        message ?? 'Please select exactly one item.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void clearSelection() {
    selectedIds.clear();
  }

  void addKnowledgeSource(KnowledgeSourceModel item) {
    knowledgeSources.insert(0, item);
    Get.snackbar(
      'Success',
      'Knowledge source added successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void updateKnowledgeSource(KnowledgeSourceModel updatedItem) {
    int index = knowledgeSources.indexWhere((item) => item.contentId == updatedItem.contentId);
    if (index != -1) {
      knowledgeSources[index] = updatedItem;
      knowledgeSources.refresh();
      Get.snackbar(
        'Success',
        'Knowledge source updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void performDelete() {
    print('Deleting selected IDs: ${selectedIds.toList()}');
    
    // Filter out the selected items from the list
    knowledgeSources.value = knowledgeSources
        .where((item) => !selectedIds.contains(item.contentId))
        .toList();

    // Clear selection after deletion
    selectedIds.clear();
    Get.snackbar(
      'Success',
      'Selected items deleted successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void clearAnalysis() {
    analysisResult.value = null;
    currentProcessingIndex.value = 0;
  }

  // Analysis states
  var currentProcessingIndex = 0.obs;
  var analysisResult = Rxn<Map<String, dynamic>>();

  Future<void> analyzeFile(PlatformFile file) async {
    try {
      isLoading.value = true;
      final response = await _apiService.multipartRequest(
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/training_data_document_analysis',
        fields: {},
        files: [
          await http.MultipartFile.fromPath('file', file.path!),
        ],
      );

      if (response.code == ApiCode.success200.index || response.data['status'] == 'success') {
        analysisResult.value = response.data;
      } else {
        Get.snackbar('Error', 'Analysis failed: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during analysis: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchKnowledgeSources();
  }

  Future<void> fetchKnowledgeSources() async {
    try {
      isLoading.value = true;
      final response = await _apiService.request(
        method: ApiMethod.get,customUrl: true,
        endpoint: Endpoints.knowledgeSources,
      );

      if (response.code == ApiCode.success200.index) {
        if (response.data is List) {
          knowledgeSources.value = (response.data as List)
              .map((item) => KnowledgeSourceModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch knowledge sources: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
