package com.example.dimao.model;

import java.io.Serializable;
import java.util.Date;

public class Task implements Serializable {
    private int id;
    private String tittle;
    private String content;
    private String createdAt;
    private Boolean isFinish;
    private String updatedAt;
    private String Reminder;
    private boolean isCheckboxVisiable;
    private int categoryId;
    private int parentId;

    public Task() {

    }

    public Task(int id, String tittle, String content, String createdAt, Boolean isFinish,
                String updatedAt, String reminder, boolean isCheckboxVisiable, int categoryId, int parentId) {
        this.id = id;
        this.tittle = tittle;
        this.content = content;
        this.createdAt = createdAt;
        this.isFinish = isFinish;
        this.updatedAt = updatedAt;
        Reminder = reminder;
        this.isCheckboxVisiable = isCheckboxVisiable;
        this.categoryId = categoryId;
        this.parentId = parentId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTittle() {
        return tittle;
    }

    public void setTittle(String tittle) {
        this.tittle = tittle;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public Boolean getFinish() {
        return isFinish;
    }

    public void setFinish(Boolean finish) {
        isFinish = finish;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getReminder() {
        return Reminder;
    }

    public void setReminder(String reminder) {
        Reminder = reminder;
    }

    public boolean isCheckboxVisiable() {
        return isCheckboxVisiable;
    }

    public void setCheckboxVisiable(boolean checkboxVisiable) {
        isCheckboxVisiable = checkboxVisiable;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }
}
