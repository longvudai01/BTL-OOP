package com.example.dimao.model;

import java.io.Serializable;
import java.util.List;

public class ListTask implements Serializable{
    private List<Task> tasks;
    private String name;

    public ListTask() {
    }

    public ListTask(List<Task> tasks, String name) {
        this.tasks = tasks;
        this.name = name;
    }

    public List<Task> getTasks() {
        return tasks;
    }

    public void setTasks(List<Task> tasks) {
        this.tasks = tasks;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
