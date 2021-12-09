#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <qcustomplot.h>
#include <QDebug>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:

    void on_draw_clicked();
    void onMouseMove(QMouseEvent *event);

    void on_checkBox_1_stateChanged(int);

    void on_checkBox_2_stateChanged(int);

    void on_checkBox_3_stateChanged(int);

    void on_checkBox_4_stateChanged(int);

    void on_checkBox_5_stateChanged(int);

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
