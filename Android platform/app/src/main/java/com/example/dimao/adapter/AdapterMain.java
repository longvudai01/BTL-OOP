package com.example.dimao.adapter;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.media.Image;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.example.dimao.dov2.DatabaseHelper;
import com.example.dimao.dov2.DetailActivity;
import com.example.dimao.dov2.R;
import com.example.dimao.model.Category;
import com.example.dimao.model.Tag;
import com.example.dimao.model.Task;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import static com.example.dimao.dov2.MainActivity.theme;

public class AdapterMain extends ArrayAdapter<Task> {
    Activity context;
    int resource;
    List<Task> objects;
    DatabaseHelper databaseHelper;
    Calendar calendar;
    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("E, dd/MM/yy, hh:mm");
    public AdapterMain(@NonNull Activity context, int resource, @NonNull List<Task> objects) {
        super(context, resource, objects);
        this.context = context;
        this.objects = objects;
        this.resource = resource;
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
//        getContext().setTheme(R.style.AppTheme2);

        LayoutInflater inflater = this.context.getLayoutInflater();
        View view = inflater.inflate(this.resource, null);
        final Task task = this.objects.get(position);

        LinearLayout linearLayoutItem = view.findViewById(R.id.linearLayoutItem);
        CheckBox chkItem = view.findViewById(R.id.chkItem);
        EditText txtTittleItem = view.findViewById(R.id.txtTittleItem);
        ImageButton imgDetailItem = view.findViewById(R.id.imgDetailItem);
        final TextView txtTimeItem = view.findViewById(R.id.txtTimeItem);
        LinearLayout linearLayoutListTaskTagItem = view.findViewById(R.id.linearLayoutListTaskTagItem);
//        TextView txtDetailCategory = view.findViewById(R.id.txtDetailCategory);
        databaseHelper = new DatabaseHelper(getContext());
        if(theme){
            imgDetailItem.setImageDrawable(context.getDrawable(android.R.drawable.ic_menu_info_details));
        }
        else {
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT);
            imgDetailItem.setLayoutParams(params);
            imgDetailItem.setImageDrawable(context.getDrawable(R.drawable.detail30));
        }

        txtTittleItem.setText(task.getTittle());
//        txtDetailCategory.setText(task.getCategoryId());
        txtTimeItem.setText(task.getCreatedAt());
        final int indexFirst = task.getCreatedAt().indexOf(",");// lấy vị trí dấu phẩy đầu tiên
        String createAt = task.getCreatedAt().substring(indexFirst + 2, indexFirst + 10); // lấy ra ngày dạng   xx/xx/xx
        String reminder = new String();
        if(task.getReminder() != null){
            reminder = task.getReminder().substring(indexFirst + 2, indexFirst + 10); // lấy ra ngày dạng   xx/xx/xx
            Date date1 = null, date2 = null;
            try {
                date1 = new SimpleDateFormat("dd/MM/yyyy").parse(createAt);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            try {
                date2 = new SimpleDateFormat("dd/MM/yyyy").parse(reminder);
            } catch (ParseException e) {
                e.printStackTrace();
            }
            long sub = date2.getTime() - date1.getTime();
            if(sub <= 1000*86400 && sub >= 0) txtTimeItem.setTextColor(Color.RED);
        }

//        if()
//        System.out.println(stringDate + "\t" + date1);
//        if(Integer.parseInt(createAt.substring(6)) > Integer.parseInt(reminder.substring(6)))

        txtTittleItem.addTextChangedListener(new TextWatcher() {
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
                if(task.getUpdatedAt() == null) txtTimeItem.setText(task.getCreatedAt());
                else txtTimeItem.setText(task.getUpdatedAt());
                databaseHelper.updateTask(task);
            }
        });

        imgDetailItem.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getContext(), DetailActivity.class);
                intent.putExtra("IDCATEGORY", task.getCategoryId());
                intent.putExtra("taskId", task.getId());
                intent.putExtra("ISADD", false);
                intent.putExtra("THEME", theme);
                getContext().startActivity(intent);
            }
        });

        if(task.isCheckboxVisiable() == true) {
            chkItem.setVisibility(View.VISIBLE);
            imgDetailItem.setVisibility(View.GONE);
        }
        else {
            chkItem.setVisibility(View.GONE);
            imgDetailItem.setVisibility(View.VISIBLE);
        }

        addListTaskTag(linearLayoutListTaskTagItem, task);
        return view;
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
    public void addListTaskTag(LinearLayout linearLayout, Task task){
        List<Tag> tags = databaseHelper.getAllTagsOfTask(task.getId());
        linearLayout.removeAllViews();
        for(int i = 0; i < tags.size(); i++){
            Button button = new Button(getContext());
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(25, 25);
            GradientDrawable drawable = (GradientDrawable) getContext().getDrawable(R.drawable.custom_tags);
            drawable.setColor(Color.parseColor(tags.get(i).getColorAsHex()));
            button.setBackground(drawable);
            button.setId(i);
            linearLayout.setGravity(Gravity.CENTER);
            params.setMargins(4,0,4,0);
            button.setLayoutParams(params); // set width, height
            linearLayout.addView(button);
        }
    }
}