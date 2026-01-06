struct nilfs_dir_entry *nilfs_dotdot(struct inode *dir, struct page **p)
{
	struct page *page = nilfs_get_page(dir, 0);
	struct nilfs_dir_entry *de = NULL;

	if (!IS_ERR(page)) {
		de = nilfs_next_entry(
			(struct nilfs_dir_entry *)page_address(page));
		*p = page;
	}
	return de;
}