package com.example.dimao.dov2;
import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.provider.CalendarContract;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.HorizontalScrollView;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import com.example.dimao.model.Tag;
import com.example.dimao.model.Task;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import static com.example.dimao.dov2.MainActivity.theme;


public class DetailActivity extends AppCompatActivity {
    LinearLayout linearLayoutListTaskTag, linearLayoutListBaseTag, linearLayoutTaskTag;
    Calendar calendar, calendar2;
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("E, dd/MM/yy, hh:mm");
    ImageButton btnDetailRemiderTime, btnDetailRemiderDate;
    Button btnDetailReminderAdd, btnCategory;
    Task task;
    EditText txtDetailTittle, txtDetailContent;
    TextView txtLineCreate, txtLineTag, txtDetailCategory;
    LinearLayout linearLayoutReminder, linearLayoutCategory, detail;
    Switch switchDetailReminder;
    Toolbar toolbarDetail;

    boolean isAdd;
    DatabaseHelper databaseHelper;
    int idCategory;
    HorizontalScrollView scrollViewBaseTag;

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if(theme){
            setTheme(R.style.AppTheme2);
        }
        else {
            setTheme(R.style.AppTheme);
        }
//        setTheme(R.style.AppTheme2);
        setContentView(R.layout.activity_detail);

        addControls();
        addEvents();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    @SuppressLint("WrongViewCast")
    private void addControls() {
        detail = findViewById(R.id.detail);




        toolbarDetail = findViewById(R.id.toolbarDetail);
        setSupportActionBar(toolbarDetail);
        getSupportActionBar().setTitle("Detail");
        // ánh xạ
        linearLayoutTaskTag = findViewById(R.id.linearLayoutTaskTag);
        scrollViewBaseTag = findViewById(R.id.scrollViewBaseTag);
        linearLayoutListTaskTag = findViewById(R.id.linearLayoutListTaskTag);
        linearLayoutListBaseTag = findViewById(R.id.linearLayoutListBaseTag);
        txtLineTag = findViewById(R.id.txtLineTag);
        btnDetailRemiderTime = findViewById(R.id.btnDetailRemiderTime);
        btnDetailRemiderDate = findViewById(R.id.btnDetailRemiderDate);
        btnDetailReminderAdd = findViewById(R.id.btnDetailReminderAdd);
        txtDetailTittle = findViewById(R.id.txtDetailTittle);
        txtDetailContent = findViewById(R.id.txtDetailContent);
        switchDetailReminder = findViewById(R.id.switchDetailReminder);
        linearLayoutReminder =findViewById(R.id.linearLayoutReminder);
        btnCategory = findViewById(R.id.btnCategory);
        txtDetailCategory =findViewById(R.id.txtDetailCategory);
        linearLayoutCategory = findViewById(R.id.linearLayoutCategory);


        if(theme){
//            Toast.makeText(DetailActivity.this, "@@", Toast.LENGTH_SHORT).show();
            detail.setBackgroundColor(Color.BLACK);
            btnDetailRemiderTime.setImageDrawable(getDrawable(R.drawable.timelight2));
            btnDetailRemiderDate.setImageDrawable(getDrawable(R.drawable.calendardark2));
            btnDetailReminderAdd.setLayoutParams(new LinearLayout.LayoutParams(150,
                    70));
            btnDetailReminderAdd.setBackgroundColor(Color.BLACK);
            btnDetailReminderAdd.setTextColor(Color.WHITE);
        }
        else {
            detail.setBackgroundColor(Color.WHITE);
            btnDetailRemiderTime.setImageDrawable(getDrawable(R.drawable.timedark));
            btnDetailRemiderDate.setImageDrawable(getDrawable(R.drawable.calendardark));
//            btnDetailRemiderTime.setBackground(getResources().getDrawable(R.drawable.timedark));
//            btnDetailRemiderDate.setBackground(getResources().getDrawable(R.drawable.calendardark));
            btnDetailReminderAdd.setBackgroundColor(Color.WHITE);
            btnDetailReminderAdd.setTextColor(Color.BLACK);
        }



        //
        databaseHelper = new DatabaseHelper(this);
        Intent intent = getIntent();
        isAdd = intent.getBooleanExtra("ISADD", false); // từ MainActivity
//        theme = intent.getBooleanExtra("THEME", false);
//
        if(!isAdd) {
            idCategory = intent.getIntExtra("IDCATEGORY", -1); // từ MainActivity  hoặc AdapterMain
            task = databaseHelper.getTask(intent.getIntExtra("taskId", -1)); // từ AdapterMain
            txtDetailTittle.setText(task.getTittle());
            txtDetailContent.setText(task.getContent());
            txtDetailCategory.setText( task.getCategoryId()+"");
            addListTaskTag(linearLayoutListTaskTag);
        }
        else {
            idCategory = intent.getIntExtra("IDCATEGORY", -1);
            linearLayoutCategory.setVisibility(View.GONE);
            btnCategory.setVisibility(View.GONE);
            scrollViewBaseTag.setVisibility(View.GONE);
            linearLayoutTaskTag.setVisibility(View.GONE);
            txtLineTag.setVisibility(View.GONE);
        }
        calendar = Calendar.getInstance();
        calendar2 = Calendar.getInstance();
        addListBaseTag();
        //
    }
    @SuppressLint("ResourceType")
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    private void addEvents() {

        // reminder
        btnDetailRemiderTime.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getTime();
            }
        });
        btnDetailRemiderDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getDate();
            }
        });
        btnDetailReminderAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                task.setReminder(simpleDateFormat.format(calendar2.getTime()));
                databaseHelper.updateTask(task);
                setReminder(task);
//                Toast.makeText(DetailActivity.this, task.getReminder(), Toast.LENGTH_SHORT).show();
            }
        });
        //end reminder
        if(!isAdd){
            txtDetailTittle.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }
                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }
                @Override
                public void afterTextChanged(Editable editable) {
                    calendar = Calendar.getInstance();
                    task.setTittle(editable.toString());
                    task.setUpdatedAt(simpleDateFormat.format(calendar.getTime()));
                    long id = databaseHelper.updateTask(task);
                }
            });

            txtDetailContent.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }
                @Override
                public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

                }
                @Override
                public void afterTextChanged(Editable editable) {
                    calendar = Calendar.getInstance();
                    task.setContent(editable.toString());
                    task.setUpdatedAt(simpleDateFormat.format(calendar.getTime()));
                    long id = databaseHelper.updateTask(task);
                }
            });
        }
        switchDetailReminder.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                if(switchDetailReminder.isChecked()){
                    linearLayoutReminder.setVisibility(View.VISIBLE);
                }
                else linearLayoutReminder.setVisibility(View.GONE);

            }
        });

        btnCategory.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(DetailActivity.this, CategoryActivity.class);
                if(!isAdd){
                    intent.putExtra("IDTASK", task.getId());
                }
                else intent.putExtra("IDTASK", (new DatabaseHelper(DetailActivity.this)).getMaxIdTask() + 1);
                startActivity(intent);
            }
        });
    }

    // add ListTaskTag
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void addListTaskTag(LinearLayout linearLayout){
        List<Tag> tags = databaseHelper.getAllTagsOfTask(task.getId());
        linearLayout.removeAllViews();
        for(int i = 0; i < tags.size(); i++){
            Button button = new Button(this);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(40, 40);
            GradientDrawable drawable = (GradientDrawable) getDrawable(R.drawable.custom_tags);
            drawable.setColor(Color.parseColor(tags.get(i).getColorAsHex()));
            button.setBackground(drawable);
            button.setId(i);
            params.setMargins(5,25,5,0);
            button.setLayoutParams(params); // set width, height
            linearLayout.addView(button);
        }
    }

    // add ListBaseTag
    @SuppressLint("NewApi")
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void addListBaseTag(){
        final List<Tag> tags = databaseHelper.getAllTags();
        for(int i = 0; i < tags.size(); i++){
            final Button button = new Button(this);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(80, 80);
            GradientDrawable drawable = (GradientDrawable) getDrawable(R.drawable.custom_tags);
            drawable.setColor(Color.parseColor(tags.get(i).getColorAsHex()));
            button.setBackground(drawable);
            params.setMargins(10,0,10,0);
            button.setLayoutParams(params); // set width, height
            button.setId(i);
            linearLayoutListBaseTag.addView(button);
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!isAdd){
                        List<Tag> tags1 = databaseHelper.getAllTagsOfTask(task.getId());
                        boolean isHave = false; // đã có tag này hay chưa , nếu có rồi thì xóa tag , chưa có thì add tag
                        for (Tag tag : tags1) {
                            if(button.getId() == tag.getId()){
                                databaseHelper.deleteTaskTag(task.getId(), tag.getId());
                                addListTaskTag(linearLayoutListTaskTag);
                                isHave = true;
                            }
                        }
                        if(!isHave) {
                            long id = databaseHelper.createTaskTag(task.getId(), button.getId());
                            addListTaskTag(linearLayoutListTaskTag);
                        }
                    }
                }
            });

        }
    }

    // Datepicker and timepicker
    void getDate(){
        DatePickerDialog.OnDateSetListener callBack = new DatePickerDialog.OnDateSetListener() {
            @Override
            public void onDateSet(DatePicker datePicker, int i, int i1, int i2) {
                calendar2.set(Calendar.YEAR, i);
                calendar2.set(Calendar.MONTH, i1);
                calendar2.set(Calendar.DAY_OF_MONTH, i2);
            }
        };
        DatePickerDialog datePickerDialog = new DatePickerDialog(DetailActivity.this,
                callBack, calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH));
        datePickerDialog.show();
    }
    void getTime(){
        TimePickerDialog.OnTimeSetListener callBack = new TimePickerDialog.OnTimeSetListener() {
            @Override
            public void onTimeSet(TimePicker timePicker, int i, int i1) {
                calendar2.set(Calendar.HOUR_OF_DAY, i);
                calendar2.set(Calendar.MINUTE, i1);
            }
        };
        TimePickerDialog timePickerDialog = new TimePickerDialog(DetailActivity.this,
                callBack,
                calendar.get(Calendar.HOUR_OF_DAY),
                calendar.get(Calendar.MINUTE),
                true);
        timePickerDialog.show();
    }

    // REMINDER
    public void setReminder(Task task){
        if (Build.VERSION.SDK_INT >= 14) {
            Intent intent = new Intent(Intent.ACTION_INSERT)
                    .setData(CalendarContract.Events.CONTENT_URI)
                    .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, calendar2.getTimeInMillis())
                    .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, calendar2.getTimeInMillis())
                    .putExtra(CalendarContract.Events.TITLE, task.getTittle())
                    .putExtra(CalendarContract.Events.DESCRIPTION, task.getContent())
//                    .putExtra(CalendarContract.Events.EVENT_LOCATION, "The gym")
                    .putExtra(CalendarContract.Events.AVAILABILITY, CalendarContract.Events.AVAILABILITY_BUSY);
//                    .putExtra(Intent.EXTRA_EMAIL, "rowan@example.com,trevor@example.com");
            startActivity(intent);
        }
        else {
            Intent intent = new Intent(Intent.ACTION_EDIT);
            intent.setType("vnd.android.cursor.item/event");
            intent.putExtra("beginTime", calendar2.getTimeInMillis());
            intent.putExtra("allDay", true);
            intent.putExtra("rrule", "FREQ=YEARLY");
            intent.putExtra("endTime", calendar2.getTimeInMillis()+60*60*1000);
            intent.putExtra("title", task.getTittle());
            intent.putExtra("description", task.getContent());
            startActivity(intent);
        }
    }

    @Override
    protected void onResume() {

        super.onResume();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.toolbar_detail, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if(item.getItemId() == R.id.btnDone){
            if(isAdd) {
                Task task = new Task();
                task.setId((new DatabaseHelper(DetailActivity.this)).getMaxIdTask() + 1);
                task.setTittle(txtDetailTittle.getText().toString());
                task.setContent(txtDetailContent.getText().toString());
                task.setCategoryId(idCategory);
                task.setCreatedAt(simpleDateFormat.format(Calendar.getInstance().getTime()));
                long id = databaseHelper.createTask(task);
                if (id == -1) {
                    Toast.makeText(DetailActivity.this, "Thêm không thành công !", Toast.LENGTH_SHORT).show();
                } else
                    Toast.makeText(DetailActivity.this, "Thêm thành công !", Toast.LENGTH_SHORT).show();
                finish();
            }
            else finish();
        }
        return super.onOptionsItemSelected(item);
    }
}
