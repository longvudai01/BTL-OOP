package com.example.dimao.dov2;

import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.Toast;

import com.example.dimao.adapter.AdapterFilter;
import com.example.dimao.adapter.AdapterMain;
import com.example.dimao.model.Category;
import com.example.dimao.model.ListTask;
import com.example.dimao.model.Tag;
import com.example.dimao.model.Task;

import org.w3c.dom.Text;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private boolean edit = false;
    Toolbar toolbarMain;
    ListView lvMain;
    AdapterMain adapterMain;
    ArrayList<Task> listTask;

    DatabaseHelper databaseHelper;
    Intent intent;
    int idIntent, categoryOrTag;
    EditText txtAddTask;
    ImageButton btnAddTask;
    boolean openFirst = true;
    TabWidget tabs;
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("E, dd/MM/yy, hh:mm");
    public static boolean theme;
    LinearLayout main, item, more;
//    SimpleDateFormat simpleDateFormat2 = new SimpleDateFormat("dd/MM/yy");
    Button btnBoLoc, btnChangeTheme;
    public static boolean isTag;
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        theme = false;

        addControls();
        addEvents();
    }



    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void addControls() {
        btnChangeTheme = findViewById(R.id.btnChangeTheme);
        main = findViewById(R.id.main);
        item = findViewById(R.id.item);
        more = findViewById(R.id.more);


        isTag = false;
        intent = getIntent();
        databaseHelper = new DatabaseHelper(this);
//        theme = databaseHelper.getTheme();
        idIntent = intent.getIntExtra("ID", -1);
        categoryOrTag = intent.getIntExtra("CATEGORYORTAG", -1);
        txtAddTask = findViewById(R.id.txtAddTask);
        btnAddTask = findViewById(R.id.btnAddTask);

        //toolbarMain
        toolbarMain = findViewById(R.id.toolbarMain);
//        toolbarMain.setBackgroundColor(Color.WHITE);
        btnBoLoc = new Button(this);
        Toolbar.LayoutParams params = new Toolbar.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        btnBoLoc.setText("Bỏ lọc");
        btnBoLoc.setVisibility(View.GONE);
        params.setMargins(250,0,0,0);
        btnBoLoc.setLayoutParams(params);
        btnBoLoc.setBackground(getDrawable(android.R.drawable.dialog_holo_light_frame));
        btnBoLoc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                recreate();
            }
        });
        toolbarMain.addView(btnBoLoc);
        setSupportActionBar(toolbarMain);


        //

        //add default Categorys
//        databaseHelper.deleteAllCategory();
        if(databaseHelper.getAllCategory().size() == 0){
            databaseHelper.createCategory1(new Category(100, "+"));
            databaseHelper.createCategory(new Category(0, "ALL"));
            databaseHelper.createCategory(new Category(1, "Done"));
        }
        //
        // add Default tags
        if(databaseHelper.getAllTags().size() == 0){
            databaseHelper.createTag(new Tag(0, "#ff0000", "ff0000"));
            databaseHelper.createTag(new Tag(1, "#fff700", "fff700"));
            databaseHelper.createTag(new Tag(2, "#22ff00", "22ff00"));
            databaseHelper.createTag(new Tag(3, "#00ffe1", "00ffe1"));
            databaseHelper.createTag(new Tag(4, "#002fff", "002fff"));
            databaseHelper.createTag(new Tag(5, "#ee00ff", "ee00ff"));
            databaseHelper.createTag(new Tag(6, "#000000", "000000"));
            databaseHelper.createTag(new Tag(7, "#e7dba2", "e7dba2"));
            databaseHelper.createTag(new Tag(8, "#395b3d", "395b3d"));
            databaseHelper.createTag(new Tag(9, "#509b9b", "509b9b"));
            databaseHelper.createTag(new Tag(10, "#475491", "475491"));
            databaseHelper.createTag(new Tag(11, "#4a1f4e", "4a1f4e"));
            databaseHelper.createTag(new Tag(12, "#d15187", "d15187"));
        }
        //
//        databaseHelper.deleteAllTask();
        //2 tab Task and Setting
        TabHost tabHost = findViewById(R.id.tabHost);
        tabHost.setup(); //set tabHost
        tabs = findViewById(android.R.id.tabs);
        tabs.setBackgroundColor(Color.WHITE);

        TabHost.TabSpec tab1 = tabHost.newTabSpec("All Tasks");
        tab1.setIndicator("", getDrawable(R.drawable.task1));//set tittle cho tab
        tab1.setContent(R.id.tab1); // content layout tab
        tabHost.addTab(tab1);

        TabHost.TabSpec tab2 = tabHost.newTabSpec("Item");
        tab2.setIndicator("", getDrawable(R.drawable.item1));
        tab2.setContent(R.id.tab2);
        tabHost.addTab(tab2);

        TabHost.TabSpec tab3 = tabHost.newTabSpec("More");
        tab3.setIndicator("", getDrawable(R.drawable.more1));//set tittle cho tab
        tab3.setContent(R.id.tab3); // content layout tab
        tabHost.addTab(tab3);
        //
        //listView
        lvMain = findViewById(R.id.lvMain);
        listTask = new ArrayList<>();
        if(openFirst){ // mở lần đầu là mở ngay trang All Tasks
            listTask = (ArrayList<Task>) databaseHelper.getAllTasks();
//            for (Task t : listTask){
//                if(t.getCategoryId() == 1) listTask.remove(t);
//            }
            getSupportActionBar().setTitle("All Tasks");
            categoryOrTag = 0;
            idIntent = 0;
            openFirst = false;
        }
        else {
            if (categoryOrTag == 0) { // 0 là category
                if(idIntent == 0){
                    getSupportActionBar().setTitle("All Tasks");
                    listTask = (ArrayList<Task>) databaseHelper.getAllTasks();
//                    for (Task t : listTask){
//                        if(t.getCategoryId() == 1) listTask.remove(t);
//                    }
                }
                else {
                    getSupportActionBar().setTitle(databaseHelper.getAllCategory().get(idIntent).getName()); // hiện tiêu đề
                    listTask = (ArrayList<Task>) databaseHelper.getAllTasksByCategory(idIntent);
                }

            } else if (categoryOrTag == 1) // 1 là tag
                listTask = (ArrayList<Task>) databaseHelper.getAllTasksByTag(idIntent);
//                for (Task t : listTask){
//                    if(t.getCategoryId() == 1) listTask.remove(t);
//                }
            getSupportActionBar().setTitle(databaseHelper.getAllTags().get(idIntent).getName()); // hiện tiêu đề
        }
        adapterMain = new AdapterMain(MainActivity.this, R.layout.item_listview_main, listTask);
        lvMain.setAdapter(adapterMain);
        adapterMain.notifyDataSetChanged();
    }

    private void addEvents() {
        // touchListener : kéo sang phải (trái ) để xóa item của listview
        SwipeDismissListViewTouchListener touchListener =
                new SwipeDismissListViewTouchListener(lvMain,
                        new SwipeDismissListViewTouchListener.DismissCallbacks() {
                            @Override
                            public boolean canDismiss(int position) {
                                return true;
                            }
                            @Override
                            public void onDismiss(ListView listView, int[] reverseSortedPositions) {
                                for (int position : reverseSortedPositions) {
//                                    Task task = databaseHelper.getTask(listTask.get(position).getId());
//                                    task.setCategoryId(1);
//                                    databaseHelper.updateTask(task);
                                    databaseHelper.deleteTask(listTask.get(position).getId());
                                    if(categoryOrTag == 0) {
                                        if(idIntent == 0) {
                                            listTask = (ArrayList<Task>) databaseHelper.getAllTasks();
                                        }
                                        else if(idIntent == 1){
                                            listTask = (ArrayList<Task>) databaseHelper.getAllTasksDone();
                                        }
                                        else {
                                            listTask = (ArrayList<Task>) databaseHelper.getAllTasksByCategory(idIntent);
                                        }
                                    }
                                    else if(categoryOrTag == 1) {
                                        listTask = (ArrayList<Task>) databaseHelper.getAllTasksByTag(idIntent);
//                                        for (Task t : listTask){
//                                            if(t.getCategoryId() == 1) listTask.remove(t);
//                                        }
                                    }
                                    adapterMain = new AdapterMain(MainActivity.this, R.layout.item_listview_main, listTask);
                                    lvMain.setAdapter(adapterMain);

                                }

                            }
                        });
        lvMain.setOnTouchListener(touchListener);

        btnAddTask.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(txtAddTask.getText().length() == 0){
                    Intent intent = new Intent(MainActivity.this, DetailActivity.class);
                    intent.putExtra("ISADD", true);
                    intent.putExtra("IDCATEGORY", idIntent);
                    startActivity(intent);
                }
                else if(txtAddTask.getText().length() > 0) {
                    Task task = new Task();
                    task.setId(databaseHelper.getMaxIdTask() + 1);
                    task.setTittle(txtAddTask.getText().toString());
                    task.setCreatedAt(simpleDateFormat.format(Calendar.getInstance().getTime()));
                    task.setCategoryId(idIntent);
                    long id = databaseHelper.createTask(task);
                    if(id == -1){
                        Toast.makeText(MainActivity.this, "Thêm không thành công !", Toast.LENGTH_SHORT).show();
                    }
                    else Toast.makeText(MainActivity.this, "Thêm thành công !", Toast.LENGTH_SHORT).show();
                    listTask = (ArrayList<Task>) databaseHelper.getAllTasks();
//                    for (Task t : listTask){
//                        if(t.getCategoryId() == 1) listTask.remove(t);
//                    }
                    adapterMain = new AdapterMain(MainActivity.this, R.layout.item_listview_main, listTask);
                    lvMain.setAdapter(adapterMain);
                    txtAddTask.setText("");
                }
            }
        });

        btnChangeTheme.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                theme = !theme;
//                Toast.makeText(MainActivity.this, theme+"", Toast.LENGTH_SHORT).show();
//                int k = databaseHelper.setTheme(!theme);
//                theme = databaseHelper.getTheme();
//                Toast.makeText(MainActivity.this, k+"", Toast.LENGTH_SHORT).show();
                if(theme){
                    setTheme(R.style.AppTheme2);
                    main.setBackgroundColor(Color.BLACK);
                    item.setBackgroundColor(Color.BLACK);
                    more.setBackgroundColor(Color.BLACK);
                    adapterMain.notifyDataSetChanged();
                }
                else {
                    setTheme((R.style.AppTheme));
                    main.setBackgroundColor(Color.WHITE);
                    item.setBackgroundColor(Color.WHITE);
                    more.setBackgroundColor(Color.WHITE);
                    adapterMain.notifyDataSetChanged();
                }
            }
        });
    }
    @Override
    protected void onResume() {
        // 3 dòng rất quan trọng để mỗi khi MainActivity onResume thì tự động load lại dữ liệu
        if(categoryOrTag == 0) {
            if(idIntent == 0){
                listTask = (ArrayList<Task>) databaseHelper.getAllTasks();
//                for (Task t : listTask){
//                    if(t.getCategoryId() == 1) listTask.remove(t);
//                }
            }
            else listTask = (ArrayList<Task>) databaseHelper.getAllTasksByCategory(idIntent);
        }
        else if(categoryOrTag == 1) {
            listTask = (ArrayList<Task>) databaseHelper.getAllTasksByTag(idIntent);
//            for (Task t : listTask){
//                if(t.getCategoryId() == 1) listTask.remove(t);
//            }
        }
        adapterMain = new AdapterMain(MainActivity.this, R.layout.item_listview_main, listTask);
        lvMain.setAdapter(adapterMain);
        super.onResume();

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.toolbar_main, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        /* edit là biến để xác nhận xem các checkbox đã hiện rồi hay chưa
        nếu edit = false tức là chưa hiện -> làm hiện
        nếu edit = true tức đã hiện -> làm mất*/
        if (item.getItemId() == R.id.btnEdit) {
            if (!edit) {
                for (Task t : listTask) {
                    t.setCheckboxVisiable(true);
                }
            } else
                for (Task t : listTask) {
                    t.setCheckboxVisiable(false);
                }

            if (edit) edit = false;
            else edit = true;
            adapterMain.notifyDataSetChanged();
        }

        if(item.getItemId() == R.id.mnuLocTheoNgay){
            filterByDay();
//            locTheoNgay(databaseHelper.getTask(1).getCreatedAt());
            isTag = false;
        }
        if(item.getItemId() == R.id.mnuLocTheoCategory){
            isTag = false;
            filterByCategory();
        }
        if(item.getItemId() == R.id.mnuLocTheoTag){
            isTag = true;
            filterByTag();
//            isTag = false;
        }
        return super.onOptionsItemSelected(item);
    }

    private void filterByTag() {
        btnBoLoc.setVisibility(View.VISIBLE);
        //lấy ra list tag Color
        ArrayList<String> listTagColor = new ArrayList<>();
        for (Tag t : databaseHelper.getAllTags()){
            listTagColor.add(t.getColorAsHex());
        }
        //lấy ra list tag id
        ArrayList<Integer> listTagId = new ArrayList<>();
        for (Tag t : databaseHelper.getAllTags()){
            listTagId.add(t.getId());
        }
        //lấy ra list các listTask
        List<ListTask> listTasks = new ArrayList<>();
        for (int i = 0; i < listTagId.size(); i++){
            List<Task> tasks = databaseHelper.getAllTasksByTag(listTagId.get(i));
//            for (Task t : listTask){
//                if(t.getCategoryId() == 1) listTask.remove(t);
//            }
            ListTask listTask = new ListTask(tasks, listTagColor.get(i));
            listTasks.add(listTask);
        }
        AdapterFilter adapterFilter = new AdapterFilter(MainActivity.this, R.layout.item_filter, listTasks);
        lvMain.setAdapter(adapterFilter);
    }

    private void filterByCategory() {
        btnBoLoc.setVisibility(View.VISIBLE);
        //lấy ra list category name
        ArrayList<String> listCategoryName = new ArrayList<>();
        for (Category c : databaseHelper.getAllCategory()){
            if((!c.getName().equals("ALL")) && (!c.getName().equals("+"))) listCategoryName.add(c.getName());
        }
        //lấy ra list category id
        ArrayList<Integer> listCategoryId = new ArrayList<>();
        for (Category c : databaseHelper.getAllCategory()){
            if((c.getId() != 100) && (c.getId() != 0)) listCategoryId.add(c.getId());
        }

        //lấy ra list các listTask
        List<ListTask> listTasks = new ArrayList<>();
        for (int i = 0; i < listCategoryName.size(); i++){
            List<Task> tasks;
            if(listCategoryId.get(i) == 1){
                tasks = databaseHelper.getAllTasksDone();
            }
            else tasks = databaseHelper.getAllTasksByCategory(listCategoryId.get(i));
            ListTask listTask = new ListTask(tasks, listCategoryName.get(i));
            listTasks.add(listTask);
        }
        AdapterFilter adapterFilter = new AdapterFilter(MainActivity.this, R.layout.item_filter, listTasks);
        lvMain.setAdapter(adapterFilter);
    }

    private void filterByDay() {
        btnBoLoc.setVisibility(View.VISIBLE);
        //lấy ra list các ngày
        ArrayList<String> listDay = new ArrayList<>();
        for (Task t : databaseHelper.getAllTasks()){
            int indexFirst = t.getCreatedAt().indexOf(",");// lấy vị trí dấu phẩy đầu tiên
            String s = t.getCreatedAt().substring(indexFirst + 2, indexFirst + 10); // lấy ra ngày dạng   xx/xx/xx
            if(!listDay.contains(s)) {
                //nếu listDay chưa có ngày của t thì thêm vào
                listDay.add(s);
            }
        }
        //lấy ra list các listTask
        List<ListTask> listTasks = new ArrayList<>();
        for (int i = 0; i < listDay.size(); i++){
            List<Task> tasks = databaseHelper.getAllTasksByDay(listDay.get(i));
//            for (Task t : listTask){
//                if(t.getCategoryId() == 1) listTask.remove(t);
//            }
            ListTask listTask = new ListTask(tasks, listDay.get(i));
            listTasks.add(listTask);
        }
        AdapterFilter adapterFilter = new AdapterFilter(MainActivity.this, R.layout.item_filter, listTasks);
        lvMain.setAdapter(adapterFilter);
    }



//    private void locTheoNgay(Date day) {
//        lvMain.setVisibility(View.GONE);
//        LinearLayout tab1 = findViewById(R.id.tab1);
//        ListView listView = new ListView(this);
//        List<Task> tasks = databaseHelper.getAllTasksByDay(simpleDateFormat2.format(day));
//        AdapterMain adapterMain = new AdapterMain(MainActivity.this, R.layout.item_listview_main, tasks);
//        lvMain.setAdapter(adapterMain);
//        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
//                ViewGroup.LayoutParams.MATCH_PARENT);
//        listView.setLayoutParams(params);
//        tab1.addView(listView);
//      }

}

