struct ext2_dir_entry_2 * ext2_dotdot (struct inode *dir, struct page **p)
{
	struct page *page = ext2_get_page(dir, 0);
	ext2_dirent *de = NULL;

	if (!IS_ERR(page)) {
		de = ext2_next_entry((ext2_dirent *) page_address(page));
		*p = page;
	}
	return de;
}