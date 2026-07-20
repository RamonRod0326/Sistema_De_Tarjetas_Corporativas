package org.example.tarjetas_corporativas.dto;

import java.util.List;

public class PageResult<T> {

    private final List<T> items;
    private final int     page;
    private final int     pageSize;
    private final long    totalCount;

    public PageResult(List<T> items, int page, int pageSize, long totalCount) {
        this.items      = items;
        this.page       = page;
        this.pageSize   = pageSize;
        this.totalCount = totalCount;
    }

    public List<T> getItems()      { return items; }
    public int     getPage()       { return page; }
    public int     getPageSize()   { return pageSize; }
    public long    getTotalCount() { return totalCount; }

    public int getTotalPages() {
        if (pageSize <= 0) return 0;
        return (int) Math.ceil((double) totalCount / pageSize);
    }

    public boolean isFirst()    { return page <= 1; }
    public boolean isLast()     { return page >= getTotalPages(); }
    public int     getPrevPage(){ return Math.max(1, page - 1); }
    public int     getNextPage(){ return Math.min(Math.max(1, getTotalPages()), page + 1); }

    /** Número de registro inicial en la página actual (base 1). */
    public long getFromRecord() { return totalCount == 0 ? 0 : (long)(page - 1) * pageSize + 1; }

    /** Número de registro final en la página actual (base 1). */
    public long getToRecord()   { return Math.min((long) page * pageSize, totalCount); }
}
