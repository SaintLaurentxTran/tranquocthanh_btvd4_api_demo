import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import 'post_form_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String mssv;
  final PostModel post;

  const PostDetailScreen({
    super.key,
    required this.mssv,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  late PostModel _currentPost;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _refreshPostDetail();
  }

  Future<void> _refreshPostDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updated =
          await _apiService.getPostDetail(widget.mssv, _currentPost.id);
      if (mounted) {
        setState(() {
          _currentPost = updated;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.redAccent, size: 36),
        title: const Text('Xác nhận xóa bài viết'),
        content: Text(
          'Bạn có chắc chắn muốn xóa bài viết "${_currentPost.title}" (ID: #${_currentPost.id}) không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa bài'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.deletePost(widget.mssv, _currentPost.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài viết thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Pop back to list and trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editPost() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PostFormScreen(
          mssv: widget.mssv,
          post: _currentPost,
        ),
      ),
    );

    if (updated == true) {
      _refreshPostDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00529C),
        foregroundColor: Colors.white,
        title: const Text(
          'Chi tiết bài viết',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa',
            onPressed: _editPost,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Xóa bài viết',
            onPressed: _deletePost,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID Chip & Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00529C).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00529C).withAlpha(40),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tag_rounded,
                              size: 14,
                              color: Color(0xFF00529C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: #${_currentPost.id}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00529C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'MSSV: ${widget.mssv}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post Title
                  SelectableText(
                    _currentPost.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Label for Content
                  Text(
                    'NỘI DUNG CHI TIẾT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Post Body Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SelectableText(
                      _currentPost.body.isEmpty
                          ? '(Không có nội dung chi tiết)'
                          : _currentPost.body,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _editPost,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00529C),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(
                            'Sửa bài viết',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _deletePost,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            'Xóa bài',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
