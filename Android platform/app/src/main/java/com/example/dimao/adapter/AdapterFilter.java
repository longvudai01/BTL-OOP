package com.example.dimao.adapter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

import com.example.dimao.dov2.R;
import com.example.dimao.model.ListTask;
import com.example.dimao.model.Task;

import java.util.ArrayList;
import java.util.List;

import static com.example.dimao.dov2.MainActivity.isTag;

public class AdapterFilter extends ArrayAdapter {
    Activity context;
    int resource;
    List objects;
    boolean b = false;
    public AdapterFilter(@NonNull Activity context, int resource, @NonNull List objects) {
        super(context, resource, objects);
        this.context = context;
        this.objects = objects;
        this.resource = resource;
    }

    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        LayoutInflater inflater = this.context.getLayoutInflater();
        View view = inflater.inflate(this.resource, null);

        Button btnTittleFilter = view.findViewById(R.id.btnTittleFilter);
        final ListView lvFilter = view.findViewById(R.id.lvFilter);

        ListTask listTask = (ListTask) this.objects.get(position);
//        Intent intent = this.context.getIntent();
//        boolean isTag = intent.getBooleanExtra("ISTAG", false);
        if(isTag){
            btnTittleFilter.setText("");
            btnTittleFilter.setBackgroundColor(Color.parseColor(listTask.getName()));
        }
        else btnTittleFilter.setText(listTask.getName());

        ArrayList<Task> tasks = (ArrayList<Task>) listTask.getTasks();
        final AdapterMain adapterMain = new AdapterMain(this.context, R.layout.item_listview_main, tasks);


        btnTittleFilter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(b){
                    lvFilter.setVisibility(View.GONE);
                }
                else {
                    lvFilter.setVisibility(View.VISIBLE);
                    lvFilter.setAdapter(adapterMain);
                }
                b = !b;
            }
        });
        return view;
    }
}
