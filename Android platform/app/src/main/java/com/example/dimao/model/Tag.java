package com.example.dimao.model;

public class Tag {

    int id;
    String colorAsHex;
    String name;

    public Tag(int id, String colorAsHex, String name) {
        this.id = id;
        this.colorAsHex = colorAsHex;
        this.name = name;
    }

    public Tag() {

    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getColorAsHex() {
        return colorAsHex;
    }

    public void setColorAsHex(String colorAsHex) {
        this.colorAsHex = colorAsHex;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Tag(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public Tag(String name) {

        this.name = name;
    }

}

