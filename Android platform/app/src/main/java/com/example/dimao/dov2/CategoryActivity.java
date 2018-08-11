package com.example.dimao.dov2;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.Image;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.dimao.model.Category;
import com.example.dimao.model.Task;

import java.util.Calendar;
import java.util.List;

import static com.example.dimao.dov2.MainActivity.theme;

public class CategoryActivity extends AppCompatActivity {

    ListView lvCategory;
    List<Category> categories;
//    List<EditText> textList;
    AdapterCategory adapter;
    DatabaseHelper databaseHelper;
    LinearLayout category;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if(theme){
            setTheme(R.style.AppTheme2);
        }
        else {
            setTheme(R.style.AppTheme);
        }
        setContentView(R.layout.activity_category);

        addControls();
        addEvents();
    }

    private void addEvents() {
        lvCategory.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                if(categories.get(i).getId() == 100){
                    final Dialog dialog = new Dialog(CategoryActivity.this);
                    dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
                    dialog.setCancelable(false);
                    dialog.setContentView(R.layout.dialong_edittext);
                    final EditText txtDialog = dialog.findViewById(R.id.txtDialog);
                    Button btnDialogThem = dialog.findViewById(R.id.btnDialogThem);
                    Button btnDialogHuy = dialog.findViewById(R.id.btnDialogHuy);
                    btnDialogThem.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Category category = new Category();
                            category.setName(txtDialog.getText().toString());
                            category.setId(databaseHelper.getMaxCategoryId() + 1);
                            databaseHelper.createCategory(category);
                            categories = databaseHelper.getAllCategory();
                            adapter = new AdapterCategory(CategoryActivity.this, R.layout.item_category, categories);
                            lvCategory.setAdapter(adapter);
                            dialog.dismiss();
                        }
                    });
                    btnDialogHuy.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            dialog.dismiss();
                        }
                    });
                    dialog.show();
                }
                else {
                    int idTask = getIntent().getIntExtra("IDTASK", -1);
                    Toast.makeText(CategoryActivity.this, idTask+"", Toast.LENGTH_SHORT).show();
                    Task task = databaseHelper.getTask(idTask);
                    task.setCategoryId(categories.get(i).getId());
                    long id = databaseHelper.updateTask(task);
                    finish();
                    Toast.makeText(CategoryActivity.this,
                            task.getCategoryId()+"", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void addControls() {
        category = findViewById(R.id.category);
        if(theme){
            category.setBackgroundColor(Color.BLACK);
        }else {
            category.setBackgroundColor(Color.WHITE);
        }
        lvCategory = findViewById(R.id.lvCategory);
        databaseHelper = new DatabaseHelper(this);
        categories = databaseHelper.getAllCategory();
        adapter = new AdapterCategory(CategoryActivity.this, R.layout.item_category, categories);
        lvCategory.setAdapter(adapter);
    }

    public class AdapterCategory extends ArrayAdapter {
        Activity context;
        int resource;
        @NonNull List objects;
        public AdapterCategory(@NonNull Activity context, int resource, @NonNull List objects) {
            super(context, resource, objects);
            this.context = context;
            this.objects = objects;
            this.resource = resource;
        }

        @NonNull
        @Override
        public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
            LayoutInflater inflater = getLayoutInflater();
            View view = inflater.inflate(this.resource, null);

            TextView txtItemCategory = view.findViewById(R.id.txtItemCategory);
            ImageView imgDauDong = view.findViewById(R.id.imgDauDong);
            if(categories.get(position).getId() == 100) imgDauDong.setVisibility(View.GONE);
            Category category = (Category) this.objects.get(position);
            txtItemCategory.setText(category.getName());

            return view;
        }
    }
}

