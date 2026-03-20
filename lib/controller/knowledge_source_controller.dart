import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/knowledge_source_model.dart';
import '../services/api/api_service.dart';
import '../services/api/endpoints.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../services/shared_pref_manager.dart';

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
  final statuses = ['COMPLETED', 'PENDING', 'FAILED'];
  final inputTypes = ['File', 'Plain Text'];
  
  // Add New Entry Form States
  var selectedInputType = 'File'.obs;
  var uploadedFiles = <PlatformFile>[].obs;
  var selectedAddCategory = ''.obs;
  var isTOCAvailable = 'N/A'.obs; // Yes, No, NA
  var tocHeadings = ''.obs;
  var plainTextContent = ''.obs;
  var textFileName = ''.obs;

  void resetAddForm() {
    selectedInputType.value = 'File';
    uploadedFiles.clear();
    selectedAddCategory.value = '';
    isTOCAvailable.value = 'N/A';
    tocHeadings.value = '';
    plainTextContent.value = '';
    textFileName.value = '';
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

  Future<void> updateKnowledgeSource(KnowledgeSourceModel updatedItem) async {
    try {
      isLoading.value = true;
      final userName = await SharedPrefManager.instance.getStringAsync(SharedPrefManager.username) ?? 'Admin';

      final response = await _apiService.request(
        method: ApiMethod.put,
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/api/knowledge-sources/edit/${updatedItem.contentId}',
        body: {
          'CONTENT_ID': updatedItem.contentId,
          'DOCUMENT_CONTENT': updatedItem.documentContent,
          'CATEGORY': updatedItem.category,
          'STATUS': updatedItem.status,
          'user_name': userName,
        },
      );

      if (response.code == ApiCode.success200.index || 
          (response.data != null && (response.data['status'] == 'success' || response.data['message'] != null || response.data['CONTENT_ID'] != null))) {
        
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
      } else {
        Get.snackbar(
          'Error',
          'Failed to update item: ${response.data?['message'] ?? 'Unknown error'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performDelete() async {
    print('Deleting selected IDs: ${selectedIds.toList()}');
    
    try {
      isLoading.value = true;
      final userName = await SharedPrefManager.instance.getStringAsync(SharedPrefManager.username) ?? 'Admin';

      final response = await _apiService.request(
        method: ApiMethod.delete,
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/api/knowledge-sources/delete',
        body: {
          'content_ids': selectedIds.toList(),
          'user_name': userName,
        },
      );

      if (response.code == ApiCode.success200.index || 
          (response.data != null && (response.data['status'] == 'success' || response.data['message'] != null))) {
        
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
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete items: ${response.data?['message'] ?? 'Unknown error'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearAnalysis() {
    analysisResult.value = null;
    previewResult.value = null;
    currentProcessingIndex.value = 0;
  }

  // Analysis states
  var currentProcessingIndex = 0.obs;
  var analysisResult = Rxn<Map<String, dynamic>>();
  var previewResult = Rxn<Map<String, dynamic>>();

  Future<void> analyzeFile(PlatformFile file) async {
    try {
      isLoading.value = true;
      analysisResult.value = null; // Clear previous result
      debugPrint('Starting analysis for: ${file.name}');
      
      final response = await _apiService.multipartRequest(
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/training_data_document_analysis',
        fields: {},
        files: [
          await http.MultipartFile.fromPath('file', file.path!),
        ],
      );

      debugPrint('API Response Code: ${response.code}');
      debugPrint('API Response Data: ${response.data}');

      if (response.code == ApiCode.success200.index || 
          (response.data != null && response.data['status'] == 'success')) {
        analysisResult.value = response.data;
        debugPrint('Analysis result updated successfully');
      } else {
        analysisResult.value = null;
        Get.snackbar('Error', 'Analysis failed: ${response.data?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      analysisResult.value = null;
      debugPrint('Error during analyzeFile: $e');
      Get.snackbar('Error', 'An error occurred during analysis: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> trainPreviewQuestions(PlatformFile file) async {
    try {
      isLoading.value = true;
      previewResult.value = null;
      debugPrint('Starting train preview for: ${file.name}');

      final response = await _apiService.multipartRequest(
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/finance_data_detection',
        fields: {
          'category': selectedAddCategory.value,
          'has_tables': isTOCAvailable.value.toLowerCase() == 'n/a'?'na':isTOCAvailable.value.toLowerCase(),
          'user_name': await SharedPrefManager.instance.getStringAsync(SharedPrefManager.username) ?? 'Admin',
        },
        files: [
          await http.MultipartFile.fromPath('file', file.path!),
        ],
      );

      debugPrint('Preview API Response: ${response.data}');

      if (response.code == ApiCode.success200.index || 
          (response.data != null && response.data['qa_pairs'] != null)) {
        previewResult.value = response.data;
      } else {
        previewResult.value = null;
        Get.snackbar('Error', 'Failed to fetch preview: ${response.data?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      previewResult.value = null;
      debugPrint('Error during trainPreviewQuestions: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addDocument(PlatformFile file) async {
    try {
      isLoading.value = true;
      debugPrint('Adding document for training: ${file.name}');

      final manualToc = isTOCAvailable.value == 'No' ?tocHeadings.value: 'AUTO_EXTRACT';
      
      final response = await _apiService.multipartRequest(
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/add-documents',
        fields: {
          'type': 'file',
          'category': selectedAddCategory.value,
          'has_toc': isTOCAvailable.value.toLowerCase() == 'n/a'?'na':isTOCAvailable.value.toLowerCase(),
          'manual_toc': manualToc.isEmpty ? 'AUTO_EXTRACT' : manualToc,
          'user_name': await SharedPrefManager.instance.getStringAsync(SharedPrefManager.username) ?? 'Admin',
          'skip_sensitive': 'false', 
        },
        files: [
          await http.MultipartFile.fromPath('file', file.path!),
        ],
      );

      debugPrint('Add Document Response: ${response.data}');

      if (response.code == ApiCode.success200.index || 
          (response.data != null && response.data['message'] != null)) {
        Get.snackbar('Success', response.data['message'] ?? 'Training started.',
            backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Error', 'Failed to start training: ${response.data?['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during addDocument: $e');
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> addPlainText() async {
    try {
      isLoading.value = true;
      debugPrint('Adding plain text knowledge source directly');

      final response = await _apiService.multipartRequest(
        customUrl: true,
        endpoint: 'http://apihub.pilogcloud.com:6735/train_plain_text',
        fields: {
          'text_data': plainTextContent.value,
          'text_data_name': textFileName.value,
          'category': selectedAddCategory.value,
          'user_name': await SharedPrefManager.instance.getStringAsync(SharedPrefManager.username) ?? 'Rahul',
        },
        files: [],
      );

      debugPrint('Add Text Response: ${response.data}');

      if (response.code == ApiCode.success200.index || 
          (response.data != null && response.data['message'] != null)) {
        return response.data;
      } else {
        Get.snackbar('Error', 'Failed to start training: ${response.data?['message'] ?? 'Unknown error'}');
        return null;
      }
    } catch (e) {
      debugPrint('Error during addPlainText: $e');
      Get.snackbar('Error', 'An error occurred: $e');
      return null;
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
