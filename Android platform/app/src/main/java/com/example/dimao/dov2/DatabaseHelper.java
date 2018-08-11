package com.example.dimao.dov2;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import com.example.dimao.model.Category;
import com.example.dimao.model.Tag;
import com.example.dimao.model.Task;

import java.util.ArrayList;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {

    // Logcat tag
    private static final String LOG = "DatabaseHelper";

    // Database Version
    private static final int DATABASE_VERSION = 1;

    // Database Name
    private static final String DATABASE_NAME = "dbTask";

    // Table Names
    private static final String TABLE_TASK = "Task";
    private static final String TABLE_TAG = "Tag";
    private static final String TABLE_CATEGORY = "Category";
    private static final String TABLE_TAG_TASK = "TagTask";
    private static final String TABLE_TASK_DONE = "TaskDone";

    // Task Table - column names
    private static final String COL_TASK_ID = "idTask";
    private static final String COL_TASK_TITTLE = "tittle";
    private static final String COL_TASK_CONTENT = "content";
    private static final String COL_TASK_CREATEDAT = "createdAt";
    private static final String COL_TASK_ISFINISH = "isFinish";
    private static final String COL_TASK_UPDATEDAT = "updatedAt";
    private static final String COL_TASK_ISCHECKBOXVISIABLE = "isCheckboxVisiable";
    private static final String COL_TASK_ID_CATEGORY = "categoryId";
    private static final String COL_TASK_PARENT = "parent";
    private static final String COL_TASK_REMINDER = "reminder";

    // Tag Table - column names
    private static final String COL_TAG_ID = "idTag";
    private static final String COL_TAG_COLORASHEX = "colorAsHex";
    private static final String COL_TAG_NAME = "name";

    // Categoy Table - column names
    private static final String COL_CATEGORY_ID = "idCategory";
    private static final String COL_CATEGORY_NAME = "name";

    private static final String TABLE_THEME = "theme";
    private static final String COL_THEME = "boolTheme";
    private static final String CREATE_TABLE_THEME = "CREATE TABLE " + TABLE_THEME
            + " ( " + COL_THEME + " BOOL )";

    // Table Create Statements
    // Todo table create statement
    private static final String CREATE_TABLE_TASK = "CREATE TABLE "
            + TABLE_TASK + "(" + COL_TASK_ID + " INTEGER PRIMARY KEY ," + COL_TASK_TITTLE
            + " TEXT," + COL_TASK_CONTENT + " TEXT," + COL_TASK_CREATEDAT + " DATE,"
            + COL_TASK_ISFINISH + " BOOL," + COL_TASK_UPDATEDAT + " DATE,"
            + COL_TASK_ISCHECKBOXVISIABLE + " BOOL," + COL_TASK_ID_CATEGORY + " INTEGER , "
            + COL_TASK_PARENT + " INTEGER," + COL_TASK_REMINDER + " TEXT " + ")";
    // Tag table create statement
    private static final String CREATE_TABLE_TAG = "CREATE TABLE " + TABLE_TAG
            + "(" + COL_TAG_ID + " INTEGER PRIMARY KEY," + COL_TAG_NAME + " TEXT," + COL_TAG_COLORASHEX + " TEXT" + ")";

    // Category table create statement
    private static final String CREATE_TABLE_CATEGORY = "CREATE TABLE "
            + TABLE_CATEGORY + "(" + COL_CATEGORY_ID + " INTEGER PRIMARY KEY," + COL_CATEGORY_NAME + " TEXT" + ")";

    // TagTask table create statement
    private static final String CREATE_TABLE_TAGTASK = "CREATE TABLE " + TABLE_TAG_TASK
            + "(" + COL_TASK_ID + " INTEGER," + COL_TAG_ID + " INTEGER, "
            + "CONSTRAINT PK PRIMARY KEY (" + COL_TASK_ID + "," + COL_TAG_ID + "))";
//    private static final String PRIMARY_KEY_TASK_TAG = ""
    private static final String CREATE_TABLE_TASK_DONE = "CREATE TABLE "
            + TABLE_TASK_DONE + "(" + COL_TASK_ID + " INTEGER PRIMARY KEY ," + COL_TASK_TITTLE
            + " TEXT," + COL_TASK_CONTENT + " TEXT," + COL_TASK_CREATEDAT + " DATE,"
            + COL_TASK_ISFINISH + " BOOL," + COL_TASK_UPDATEDAT + " DATE,"
            + COL_TASK_ISCHECKBOXVISIABLE + " BOOL," + COL_TASK_ID_CATEGORY + " INTEGER , "
            + COL_TASK_PARENT + " INTEGER," + COL_TASK_REMINDER + " TEXT " + ")";

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {

        // creating required tables
        db.execSQL(CREATE_TABLE_TASK);
        db.execSQL(CREATE_TABLE_TASK_DONE);
        db.execSQL(CREATE_TABLE_TAG);
        db.execSQL(CREATE_TABLE_CATEGORY);
        db.execSQL(CREATE_TABLE_TAGTASK);
        db.execSQL(CREATE_TABLE_THEME);

    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // on upgrade drop older tables
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_TASK);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_TASK_DONE);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_TAG);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_CATEGORY);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_TAG_TASK);
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_THEME);

        // create new tables
        onCreate(db);
    }

    /*
     * Creating a Task
     */
    public long createTask(Task task) {
//        , long[] tagIds
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_TASK_ID, task.getId());
        contentValues.put(COL_TASK_TITTLE, task.getTittle());
        contentValues.put(COL_TASK_CONTENT, task.getContent());
        contentValues.put(COL_TASK_CREATEDAT, task.getCreatedAt());
        contentValues.put(COL_TASK_ISFINISH, task.getFinish());
        contentValues.put(COL_TASK_UPDATEDAT, task.getUpdatedAt());
        contentValues.put(COL_TASK_ISCHECKBOXVISIABLE, task.isCheckboxVisiable());
        contentValues.put(COL_TASK_ID_CATEGORY, task.getCategoryId());
        contentValues.put(COL_TASK_PARENT, task.getParentId());
        contentValues.put(COL_TASK_REMINDER, task.getReminder());

        // insert row
        long taskId = db.insert(TABLE_TASK, null, contentValues);

        return taskId;
    }

    /*
     * get single Task
     */
    public Task getTask(long taskId) {
        SQLiteDatabase db = this.getReadableDatabase();
        String selectQuery = "SELECT  * FROM " + TABLE_TASK + " WHERE "
                + COL_TASK_ID + " = " + taskId;
        Log.e(LOG, selectQuery);
        Cursor c = db.rawQuery(selectQuery, null);
        if (c != null)
            c.moveToFirst();
        Task task = new Task();
        task.setId(c.getInt(c.getColumnIndex(COL_TASK_ID)));
        task.setTittle(c.getString(c.getColumnIndex(COL_TASK_TITTLE)));
        task.setContent(c.getString(c.getColumnIndex(COL_TASK_CONTENT)));
        task.setCreatedAt(c.getString(c.getColumnIndex(COL_TASK_CREATEDAT)));
        task.setFinish(c.getInt(c.getColumnIndex(COL_TASK_ISFINISH)) > 0);
        task.setUpdatedAt(c.getString(c.getColumnIndex(COL_TASK_UPDATEDAT)));
        task.setCheckboxVisiable(c.getInt(c.getColumnIndex(COL_TASK_ISCHECKBOXVISIABLE)) > 0);
//        task.setCategoryId(c.getInt(c.getColumnIndex(COL_TASK_ID_CATEGORY)));
        task.setParentId(c.getInt(c.getColumnIndex(COL_TASK_PARENT)));
        task.setReminder(c.getString(c.getColumnIndex(COL_TASK_REMINDER)));
        return task;
    }

    /*
     * getting all Tasks
     * */
    public List<Task> getAllTasks() {
        List<Task> tasks = new ArrayList<Task>();
        String selectQuery = "SELECT  * FROM " + TABLE_TASK;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Task task = new Task();
                task.setId(c.getInt(c.getColumnIndex(COL_TASK_ID)));
                task.setTittle(c.getString(c.getColumnIndex(COL_TASK_TITTLE)));
                task.setContent(c.getString(c.getColumnIndex(COL_TASK_CONTENT)));
                task.setCreatedAt(c.getString(c.getColumnIndex(COL_TASK_CREATEDAT)));
                task.setFinish(c.getInt(c.getColumnIndex(COL_TASK_ISFINISH)) > 0);
                task.setUpdatedAt(c.getString(c.getColumnIndex(COL_TASK_UPDATEDAT)));
                task.setCheckboxVisiable(c.getInt(c.getColumnIndex(COL_TASK_ISCHECKBOXVISIABLE)) > 0);
                task.setCategoryId(c.getInt(c.getColumnIndex(COL_TASK_ID_CATEGORY)));
                task.setParentId(c.getInt(c.getColumnIndex(COL_TASK_PARENT)));
                task.setReminder(c.getString(c.getColumnIndex(COL_TASK_REMINDER)));

                // adding to task list
                tasks.add(task);
            } while (c.moveToNext());
        }

        return tasks;
    }

    public int getMaxIdTask(){
        List<Task> tasks = getAllTasks();
        int max = 0;
        for (Task t : tasks){
            if(t.getId() > max) max = t.getId();
        }
        return max;
    }

    /*
     * getting all tasks under single tag
     * */
    public List<Task> getAllTasksByTag(int tagId) {
        List<Task> tasks = new ArrayList<Task>();
        String selectQuery = "SELECT  * FROM " + TABLE_TASK + " t, "
                + TABLE_TAG_TASK + " tt " + " WHERE tt." + COL_TAG_ID + " = " + tagId
                + " AND t." + COL_TASK_ID + " = tt." + COL_TASK_ID;
        Log.e(LOG, selectQuery);

        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Task task = new Task();
                task.setId(c.getInt(c.getColumnIndex(COL_TASK_ID)));
                task.setTittle(c.getString(c.getColumnIndex(COL_TASK_TITTLE)));
                task.setContent(c.getString(c.getColumnIndex(COL_TASK_CONTENT)));
                task.setCreatedAt(c.getString(c.getColumnIndex(COL_TASK_CREATEDAT)));
                task.setFinish(c.getInt(c.getColumnIndex(COL_TASK_ISFINISH)) > 0);
                task.setUpdatedAt(c.getString(c.getColumnIndex(COL_TASK_UPDATEDAT)));
                task.setCheckboxVisiable(c.getInt(c.getColumnIndex(COL_TASK_ISCHECKBOXVISIABLE)) > 0);
                task.setCategoryId(c.getInt(c.getColumnIndex(COL_TASK_ID_CATEGORY)));
                task.setParentId(c.getInt(c.getColumnIndex(COL_TASK_PARENT)));
                task.setReminder(c.getString(c.getColumnIndex(COL_TASK_REMINDER)));
                // adding to task list
                tasks.add(task);
            } while (c.moveToNext());
        }

        return tasks;
    }

    // getAllTaskByCategory
    public List<Task> getAllTasksByCategory(int categoryId) {
        List<Task> tasks = new ArrayList<Task>();
        String selectQuery = "SELECT  * FROM " + TABLE_TASK + " t "
                + " WHERE t." + COL_TASK_ID_CATEGORY + " = " + categoryId;
        Log.e(LOG, selectQuery);

        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Task task = new Task();
                task.setId(c.getInt(c.getColumnIndex(COL_TASK_ID)));
                task.setTittle(c.getString(c.getColumnIndex(COL_TASK_TITTLE)));
                task.setContent(c.getString(c.getColumnIndex(COL_TASK_CONTENT)));
                task.setCreatedAt(c.getString(c.getColumnIndex(COL_TASK_CREATEDAT)));
                task.setFinish(c.getInt(c.getColumnIndex(COL_TASK_ISFINISH)) > 0);
                task.setUpdatedAt(c.getString(c.getColumnIndex(COL_TASK_UPDATEDAT)));
                task.setCheckboxVisiable(c.getInt(c.getColumnIndex(COL_TASK_ISCHECKBOXVISIABLE)) > 0);
                task.setCategoryId(c.getInt(c.getColumnIndex(COL_TASK_ID_CATEGORY)));
                task.setParentId(c.getInt(c.getColumnIndex(COL_TASK_PARENT)));
                task.setReminder(c.getString(c.getColumnIndex(COL_TASK_REMINDER)));

                // adding to task list
                tasks.add(task);
            } while (c.moveToNext());
        }

        return tasks;
    }

    // getAllTasksByDay
    public List<Task> getAllTasksByDay(String day) {
        List<Task> tasks = new ArrayList<Task>();
        String selectQuery = "SELECT  * FROM " + TABLE_TASK + " t "
                + " WHERE t." + COL_TASK_CREATEDAT + " like " + "'%, " + day + ",%'";
        Log.e(LOG, selectQuery);

        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Task task = new Task();
                task.setId(c.getInt(c.getColumnIndex(COL_TASK_ID)));
                task.setTittle(c.getString(c.getColumnIndex(COL_TASK_TITTLE)));
                task.setContent(c.getString(c.getColumnIndex(COL_TASK_CONTENT)));
                task.setCreatedAt(c.getString(c.getColumnIndex(COL_TASK_CREATEDAT)));
                task.setFinish(c.getInt(c.getColumnIndex(COL_TASK_ISFINISH)) > 0);
                task.setUpdatedAt(c.getString(c.getColumnIndex(COL_TASK_UPDATEDAT)));
                task.setCheckboxVisiable(c.getInt(c.getColumnIndex(COL_TASK_ISCHECKBOXVISIABLE)) > 0);
                task.setCategoryId(c.getInt(c.getColumnIndex(COL_TASK_ID_CATEGORY)));
                task.setParentId(c.getInt(c.getColumnIndex(COL_TASK_PARENT)));
                task.setReminder(c.getString(c.getColumnIndex(COL_TASK_REMINDER)));

                // adding to task list
                tasks.add(task);
            } while (c.moveToNext());
        }

        return tasks;
    }

    /*
     * Updating a task
     */
    public int updateTask(Task task) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
//        contentValues.put(COL_TASK_ID, task.getId());
        contentValues.put(COL_TASK_TITTLE, task.getTittle());
        contentValues.put(COL_TASK_CONTENT, task.getContent());
        contentValues.put(COL_TASK_CREATEDAT, task.getCreatedAt());
        contentValues.put(COL_TASK_ISFINISH, task.getFinish());
        contentValues.put(COL_TASK_UPDATEDAT, task.getUpdatedAt());
        contentValues.put(COL_TASK_ISCHECKBOXVISIABLE, task.isCheckboxVisiable());
        contentValues.put(COL_TASK_ID_CATEGORY, task.getCategoryId());
        contentValues.put(COL_TASK_PARENT, task.getParentId());
        contentValues.put(COL_TASK_REMINDER, task.getReminder());


        // updating row
        return db.update(TABLE_TASK, contentValues, COL_TASK_ID + " = ?",
                new String[] { String.valueOf(task.getId())});
    }

    /*
     * Deleting a task
     */
    public void deleteTask(long taskId) {
        SQLiteDatabase db = this.getWritableDatabase();
        createTaskDone(getTask(taskId));
        db.delete(TABLE_TASK, COL_TASK_ID + " = ?",
                new String[] { String.valueOf(taskId) });
        deleteAllTagOfTask(taskId);
    }

    public void deleteAllTask(){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_TASK, null, null);
    }

    /*
     * Creating tag
     */
    public long createTag(Tag tag) {
        SQLiteDatabase db = this.getWritableDatabase();

        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_TAG_ID, tag.getId());
        contentValues.put(COL_TAG_NAME, tag.getName());
        contentValues.put(COL_TAG_COLORASHEX, tag.getColorAsHex());
        // insert row
        long tag_id = db.insert(TABLE_TAG, null, contentValues);
        return tag_id;
    }

    // get 1 Tag
    public Tag getTag(long tagId) {
        SQLiteDatabase db = this.getReadableDatabase();
        String selectQuery = "SELECT  * FROM " + TABLE_TAG + " WHERE "
                + COL_TAG_ID + " = " + tagId;
        Log.e(LOG, selectQuery);
        Cursor c = db.rawQuery(selectQuery, null);
        if (c != null)
            c.moveToFirst();
        Tag tag = new Tag();
        tag.setId(c.getInt(c.getColumnIndex(COL_TAG_ID)));
        tag.setName(c.getString(c.getColumnIndex(COL_TAG_NAME)));
        tag.setColorAsHex(c.getString(c.getColumnIndex(COL_TAG_COLORASHEX)));
        return tag;
    }
    /**
     * getting all tags
     * */
    public List<Tag> getAllTags() {
        List<Tag> tags = new ArrayList<Tag>();
        String selectQuery = "SELECT  * FROM " + TABLE_TAG;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Tag tag = new Tag();
//                tag.setId(c.getInt((c.getColumnIndex(KEY_ID))));
                tag.setId(c.getInt(c.getColumnIndex(COL_TAG_ID)));
                tag.setName(c.getString(c.getColumnIndex(COL_TAG_NAME)));
                tag.setColorAsHex(c.getString(c.getColumnIndex(COL_TAG_COLORASHEX)));

                // adding to tags list
                tags.add(tag);
            } while (c.moveToNext());
        }
        return tags;
    }

    /*
     * Updating a tag
     */
    public int updateTag(Tag tag) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
//        contentValues.put(COL_TAG_ID, tag.getId());
        contentValues.put(COL_TAG_NAME, tag.getName());
        contentValues.put(COL_TAG_COLORASHEX, tag.getColorAsHex());

        // updating row
        return db.update(TABLE_TAG, contentValues, COL_TAG_ID + " = ?",
                new String[] { String.valueOf(tag.getId()) });
    }

    /*
     * Deleting a tag
     */
    public void deleteTag(int tagId) {
        SQLiteDatabase db = this.getWritableDatabase();
        // now delete the tag
        db.delete(TABLE_TAG, COL_TAG_ID + " = ?",
                new String[] {String.valueOf(tagId)});
    }

    /*
     * Creating tag_task
     */
    public long createTaskTag(long taskId, long tagId) {
        SQLiteDatabase db = this.getWritableDatabase();

        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_TASK_ID, taskId);
        contentValues.put(COL_TAG_ID, tagId);
        long id = db.insert(TABLE_TAG_TASK, null, contentValues);
        return id;
    }

    public void deleteAllTag(){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_TAG, null, null);
    }

    /*
     * Delete 1 tag of Task
     */
    public void deleteTaskTag(long taskId, long tagId){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_TAG_TASK, COL_TAG_ID + " = ? AND " + COL_TASK_ID + " = ?",
                new String[] {String.valueOf(tagId), String.valueOf(taskId)});
    }

    /*
     * Delete ALL tag of Task
     */
    public void deleteAllTagOfTask(long taskId){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_TAG_TASK, COL_TASK_ID + " =?" ,
                new String[] {String.valueOf(taskId)});
    }

    // closing database
    public void closeDB() {
        SQLiteDatabase db = this.getReadableDatabase();
        if (db != null && db.isOpen())
            db.close();
    }

    // get All Tags Of Task
    public List<Tag> getAllTagsOfTask(long taskId) {
        List<Tag> tags = new ArrayList<Tag>();
        String selectQuery = "SELECT * FROM "
                + TABLE_TAG_TASK + " tt ," + TABLE_TAG +" t WHERE tt."
                + COL_TASK_ID + " = '" + taskId + "' AND " + "t." + COL_TAG_ID + "="
                + "tt." + COL_TAG_ID;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

//        if(c.isNull(1))
        while (c.moveToNext()){
                Tag tag = new Tag();
                tag.setId(c.getInt(c.getColumnIndex(COL_TAG_ID)));
                tag.setName(c.getString(c.getColumnIndex(COL_TAG_NAME)));
                tag.setColorAsHex(c.getString(c.getColumnIndex(COL_TAG_COLORASHEX)));
                tags.add(tag);
            }
        return tags;
    }

    // Category
    // create Category
         public long createCategory1(Category category) {
            SQLiteDatabase db = this.getWritableDatabase();
//            deleteCategory(100);
            ContentValues contentValues = new ContentValues();
            contentValues.put(COL_CATEGORY_ID, category.getId());
            contentValues.put(COL_CATEGORY_NAME, category.getName());
            // insert row
            long id = db.insert(TABLE_CATEGORY, null, contentValues);
            return id;
        }

        public int getMaxCategoryId(){
            int max = 0;
            List<Category> categories = getAllCategory();
//            categories.remove()
            for (Category c : categories){
                if(c.getId() != 100){
                    if(c.getId() > max) max = c.getId();
                }
            }
            return max;
        }

        public void createCategory(Category category){
            Category category100 = getCategory(100);
            deleteCategory(100);
            createCategory1(category);
            createCategory1(category100);
        }
    // getAllCategory
    public List<Category> getAllCategory(){
        List<Category> categories = new ArrayList<Category>();
        String selectQuery = "SELECT  * FROM " + TABLE_CATEGORY;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Category category = new Category();
                category.setId(c.getInt(c.getColumnIndex(COL_CATEGORY_ID)));
                category.setName(c.getString(c.getColumnIndex(COL_CATEGORY_NAME)));
                categories.add(category);
            } while (c.moveToNext());
        }
        return categories;
    }

    // get 1 Category
    public Category getCategory(int categoryId){
        String selectQuery = "SELECT  * FROM " + TABLE_CATEGORY + " WHERE "
                + COL_CATEGORY_ID + "=" + categoryId ;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);
        if (c != null)
            c.moveToFirst();
        Category category = new Category();
        category.setId(c.getInt(c.getColumnIndex(COL_CATEGORY_ID)));
        category.setName(c.getString(c.getColumnIndex(COL_CATEGORY_NAME)));
        return category;
    }
    // get Category Of Task
    public Category getCategoryOfTask(long taskId){
        String selectQuery = "SELECT * FROM " + TABLE_CATEGORY + " c ," + TABLE_TASK + " t WHERE c."
                + COL_CATEGORY_ID + " = t." + COL_TASK_ID_CATEGORY + " AND t."
                + COL_TASK_ID + " = " + taskId;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);
        if (c != null)
            c.moveToFirst();
        Category category = new Category();
        category.setId(c.getInt(c.getColumnIndex(COL_CATEGORY_ID)));
        category.setName(c.getString(c.getColumnIndex(COL_CATEGORY_NAME)));
        return category;
    }

    //delete All Category
    public void deleteAllCategory(){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_CATEGORY, null, null);
    }

    //
    public void deleteCategory(long categoryId) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_CATEGORY, COL_CATEGORY_ID + " = ?",
                new String[] { String.valueOf(categoryId) });
    }

    public long createTaskDone(Task task) {
//        , long[] tagIds
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_TASK_ID, task.getId());
        contentValues.put(COL_TASK_TITTLE, task.getTittle());
        contentValues.put(COL_TASK_CONTENT, task.getContent());
        contentValues.put(COL_TASK_CREATEDAT, task.getCreatedAt());
        contentValues.put(COL_TASK_ISFINISH, task.getFinish());
        contentValues.put(COL_TASK_UPDATEDAT, task.getUpdatedAt());
        contentValues.put(COL_TASK_ISCHECKBOXVISIABLE, task.isCheckboxVisiable());
        contentValues.put(COL_TASK_ID_CATEGORY, task.getCategoryId());
        contentValues.put(COL_TASK_PARENT, task.getParentId());
        contentValues.put(COL_TASK_REMINDER, task.getReminder());


        // insert row
        long taskId = db.insert(TABLE_TASK_DONE, null, contentValues);

        return taskId;
    }

    public List<Task> getAllTasksDone() {
        List<Task> tasks = new ArrayList<Task>();
        String selectQuery = "SELECT  * FROM " + TABLE_TASK_DONE;
        Log.e(LOG, selectQuery);
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);

        // looping through all rows and adding to list
        if (c.moveToFirst()) {
            do {
                Task task = new Task();
                task.setId(c.getInt(c.getColumnIndex(COL_TASK_ID)));
                task.setTittle(c.getString(c.getColumnIndex(COL_TASK_TITTLE)));
                task.setContent(c.getString(c.getColumnIndex(COL_TASK_CONTENT)));
                task.setCreatedAt(c.getString(c.getColumnIndex(COL_TASK_CREATEDAT)));
                task.setFinish(c.getInt(c.getColumnIndex(COL_TASK_ISFINISH)) > 0);
                task.setUpdatedAt(c.getString(c.getColumnIndex(COL_TASK_UPDATEDAT)));
                task.setCheckboxVisiable(c.getInt(c.getColumnIndex(COL_TASK_ISCHECKBOXVISIABLE)) > 0);
                task.setCategoryId(c.getInt(c.getColumnIndex(COL_TASK_ID_CATEGORY)));
                task.setParentId(c.getInt(c.getColumnIndex(COL_TASK_PARENT)));
                task.setReminder(c.getString(c.getColumnIndex(COL_TASK_REMINDER)));

                // adding to task list
                tasks.add(task);
            } while (c.moveToNext());
        }
        return tasks;
    }

    public boolean getTheme(){
        String selectQuery = "SELECT " + COL_THEME + " FROM " + TABLE_THEME;
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor c = db.rawQuery(selectQuery, null);
        boolean theme = false;
        if(c.moveToFirst()){
            do {
                theme = c.getInt(c.getColumnIndex(COL_THEME)) > 0;
            } while (c.moveToNext());
        }
        return theme;
    }

    public int setTheme(boolean b){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_THEME, b);
        return db.update(TABLE_THEME, contentValues, COL_THEME + " = ?",
                new String[] {String.valueOf(!b)} );
    }
}
