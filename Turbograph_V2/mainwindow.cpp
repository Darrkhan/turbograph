#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <fstream>
#include <iostream>
#include <QList>
#include <iostream>
#include <chrono>
#include <random>
#include <string>
#include <QString>

using namespace std;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    //Initialisation de notre zone de dessin dans l'interface
    ui->setupUi(this);

    ui->customPlot->addGraph();
    ui->customPlot->graph(0)->setScatterStyle(QCPScatterStyle::ssNone);
    ui->customPlot->graph()->setLineStyle(QCPGraph::lsLine);
    ui->customPlot->xAxis->setLabel("X"); //Affichage de l'axe X
    ui->customPlot->xAxis->setLabel("Y"); //Affichage de l'axe Y
    ui->checkBox_1->setVisible(false);
    ui->checkBox_2->setVisible(false);
    ui->checkBox_3->setVisible(false);
    ui->checkBox_4->setVisible(false);
    ui->checkBox_5->setVisible(false);

    ui->customPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom | QCP::iSelectPlottables);



    ui->customPlot->legend->setVisible(true);
    QFont legendFont = font();  // start out with MainWindow's font..
    legendFont.setPointSize(9); // and make a bit smaller for legend
    ui->customPlot->legend->setFont(legendFont);
    ui->customPlot->legend->setBrush(QBrush(QColor(255,255,255,230)));
    // by default, the legend is in the inset layout of the main axis rect. So this is how we access it to change legend placement:
    ui->customPlot->axisRect()->insetLayout()->setInsetAlignment(0, Qt::AlignBottom|Qt::AlignRight);
}

MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::on_draw_clicked()
{
    //Fonction permettant l'utilisation de random
    random_device rd;
       mt19937::result_type seed = rd() ^ (
               (mt19937::result_type)
               chrono::duration_cast<chrono::seconds>(
                   chrono::system_clock::now().time_since_epoch()
                   ).count() +
               (mt19937::result_type)
               chrono::duration_cast<chrono::microseconds>(
                   chrono::high_resolution_clock::now().time_since_epoch()
                   ).count() );

       mt19937 gen(seed);
       uniform_int_distribution<unsigned> distrib(64, 255);

       cout << '\n';
    // Cr??ation d'un objet QFile
    QFile file("C:/Users/Administrateur/Documents/TurboGraph_V2/Langage/test.txt");
    // On ouvre notre fichier en lecture seule et on v??rifie l'ouverture
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;

    // Cr??ation d'un objet QTextStream ?? partir de notre objet QFile
    QTextStream flux(&file);
    // ??criture des diff??rentes lignes dans le fichier
    flux << ui->function->toPlainText();


    system ("start C:\\Users\\Administrateur\\Documents\\TurboGraph_V2\\Langage\\langage.exe");

    ifstream monFlux("C:/Users/Administrateur/Documents/TurboGraph_V2/Langage/points.txt");  //Ouverture d'un fichier en lecture



    if(monFlux){

        for(int i = 0; i < ui->customPlot->graphCount(); i++){
            ui->customPlot->graph(i)->addToLegend();
        }
        QVector<double> x, y;
        QString qstr;
        //Initialisation de nos variables
        string line;
        string ix;
        string ygrec;
        string fct = "";
        int nbFct = 0;
        //Boucle while permettant de r??cuperer les coordonn??es de chaque point, on detecte aussi le changement de courbe.
        while(getline(monFlux, line)){
            int addr = line.find(' ');
            int addr2 = line.find(';');
            ix = line.substr(0, addr);
            ygrec = line.substr(addr, addr2 - addr);
            if(fct == ""){
                fct = line.substr(addr2 + 1, line.length());
                x.push_front(stod(ix));
                y.push_front(stod(ygrec));
            } else {
                if( fct == line.substr(addr2 + 1, line.length())){
                    x.push_front(stod(ix));
                    y.push_front(stod(ygrec));
                } else {
                    if(nbFct + 1 > ui->customPlot->graphCount()){
                        ui->customPlot->addGraph();
                    }
                    qstr = QString::fromStdString(fct) + "(x)";
                    ui->customPlot->graph(nbFct)->setName(qstr);
                    fct = line.substr(addr2 + 1, line.length());
                    ui->customPlot->graph(nbFct)->setData(x,y);
                    ui->customPlot->graph(nbFct)->setPen(QColor(distrib(gen), distrib(gen), distrib(gen)));//couleur de courbe al??atoire.
                    ui->customPlot->graph(nbFct)->setVisible(false);

                    nbFct++;


                    x.clear();
                    y.clear();
                }
            }

        }
        if(nbFct + 1 > ui->customPlot->graphCount()){
            ui->customPlot->addGraph();
        }
        ui->customPlot->graph(nbFct)->setData(x,y);
        ui->customPlot->graph(nbFct)->setPen(QColor(distrib(gen), distrib(gen), distrib(gen), 255));
        qstr = QString::fromStdString(fct) + "(x)";
        ui->customPlot->graph(nbFct)->setName(qstr);
        ui->customPlot->graph(nbFct)->setVisible(false);
        nbFct++;
        x.clear();
        y.clear();

        for(int i = nbFct; i < ui->customPlot->graphCount(); i++){
            ui->customPlot->graph(i)->data()->clear();
            ui->customPlot->graph(i)->removeFromLegend();
        }
        //Initialisation des Checkbox permettant l'affichage ou non des courbes.

        if(nbFct >= 1){
            ui->checkBox_1->setVisible(true);
            ui->checkBox_1->setChecked(true);
            ui->customPlot->graph(0)->setVisible(true);
        }else{ui->checkBox_1->setVisible(false);}
        if(nbFct >= 2){
            ui->checkBox_2->setVisible(true);
            ui->checkBox_2->setChecked(false);
            ui->customPlot->graph(1)->setVisible(false);
        }else{ui->checkBox_2->setVisible(false);}
        if(nbFct >= 3){
            ui->checkBox_3->setVisible(true);
            ui->checkBox_3->setChecked(false);
            ui->customPlot->graph(2)->setVisible(false);
        }else{ui->checkBox_3->setVisible(false);}
        if(nbFct >= 4){
            ui->checkBox_4->setVisible(true);
            ui->checkBox_4->setChecked(false);
            ui->customPlot->graph(3)->setVisible(false);
        }else{ui->checkBox_4->setVisible(false);}
        if(nbFct >= 5){
            ui->checkBox_5->setVisible(true);
            ui->checkBox_5->setChecked(false);
            ui->customPlot->graph(4)->setVisible(false);
        }else{ui->checkBox_5->setVisible(false);}

        ui->customPlot->rescaleAxes();
        ui->customPlot->replot();


    }
    else
    {
        cout << "ERREUR: Impossible d'ouvrir le fichier en lecture." << endl;
    }


    connect(ui->customPlot, SIGNAL(mouseMove(QMouseEvent*)), this, SLOT(onMouseMove(QMouseEvent*)));

}

void MainWindow::onMouseMove(QMouseEvent *event) //r??cup??ration des coordonn??es du curseur.
{
    double x, y;
    x = this->ui->customPlot->xAxis->pixelToCoord(event->pos().x());
    y = this->ui->customPlot->yAxis->pixelToCoord(event->pos().y());

    QString str = QString::number(x);
    QString str2 = QString::number(y);
    ui->lineEdit->setText("x : " + str + "  " + " y : " + str2);

    qDebug() << x << "&" << y;

}

//Fonctionnement des checkbox.
void MainWindow::on_checkBox_1_stateChanged(int)
{
   int visibleOrNot = ui->customPlot->graph(0)->visible();
   if (visibleOrNot == true){
        ui->customPlot->graph(0)->setVisible(false);
   }else {ui->customPlot->graph(0)->setVisible(true);}
   ui->customPlot->rescaleAxes();
   ui->customPlot->replot();
}


void MainWindow::on_checkBox_2_stateChanged(int)
{
    int visibleOrNot = ui->customPlot->graph(1)->visible();
    if (visibleOrNot == true){
         ui->customPlot->graph(1)->setVisible(false);
    }else {ui->customPlot->graph(1)->setVisible(true);}
    ui->customPlot->rescaleAxes();
    ui->customPlot->replot();
}

void MainWindow::on_checkBox_3_stateChanged(int)
{
    int visibleOrNot = ui->customPlot->graph(2)->visible();
    if (visibleOrNot == true){
         ui->customPlot->graph(2)->setVisible(false);
    }else {ui->customPlot->graph(2)->setVisible(true);}
    ui->customPlot->rescaleAxes();
    ui->customPlot->replot();
}

void MainWindow::on_checkBox_4_stateChanged(int)
{
    int visibleOrNot = ui->customPlot->graph(3)->visible();
    if (visibleOrNot == true){
         ui->customPlot->graph(3)->setVisible(false);
    }else {ui->customPlot->graph(3)->setVisible(true);}
    ui->customPlot->rescaleAxes();
    ui->customPlot->replot();
}

void MainWindow::on_checkBox_5_stateChanged(int)
{
    int visibleOrNot = ui->customPlot->graph(4)->visible();
    if (visibleOrNot == true){
         ui->customPlot->graph(4)->setVisible(false);
    }else {ui->customPlot->graph(4)->setVisible(true);}
    ui->customPlot->rescaleAxes();
    ui->customPlot->replot();
}
