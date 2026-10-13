import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class PostFormScreen extends StatefulWidget {
  final String mssv;
  final PostModel? post; // null = tạo mới, khác null = chỉnh sửa

  const PostFormScreen({
    super.key,
    required this.mssv,
    this.post,
  });

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _bodyController.text = widget.post!.body;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    try {
      if (_isEditing) {
        await _apiService.updatePost(
          widget.mssv,
          widget.post!.id,
          title,
          body,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật bài viết thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await _apiService.createPost(
          widget.mssv,
          title,
          body,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo bài viết mới thành công!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Trả về true để màn hình trước tải lại
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00529C),
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'Cập nhật bài viết' : 'Thêm bài viết mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isEditing)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: Color(0xFF00529C)),
                      const SizedBox(width: 8),
                      Text(
                        'Đang chỉnh sửa bài viết ID: #${widget.post!.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF00529C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Tiêu đề
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề bài viết *',
                  hintText: 'Nhập tiêu đề bài viết...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tiêu đề bài viết không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Nội dung
              TextFormField(
                controller: _bodyController,
                minLines: 5,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Nội dung bài viết *',
                  hintText: 'Nhập nội dung chi tiết bài viết...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nội dung bài viết không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Nút Lưu / Hủy
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy bỏ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00529C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _isLoading
                            ? 'Đang lưu...'
                            : (_isEditing ? 'Lưu thay đổi' : 'Đăng bài viết'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
