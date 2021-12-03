#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <fstream>
#include <iostream>
#include <QList>

using namespace std;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    ui->customPlot->addGraph();
    ui->customPlot->graph(0)->setScatterStyle(QCPScatterStyle::ssCircle);
    ui->customPlot->graph()->setLineStyle(QCPGraph::lsLine);
    ui->customPlot->xAxis->setLabel("X");
    ui->customPlot->xAxis->setLabel("Y");

    ui->customPlot->setInteractions(QCP::iRangeDrag | QCP::iRangeZoom | QCP::iSelectPlottables);


}

MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::on_draw_clicked()
{
    // Création d'un objet QFile
    QFile file("C:/Users/Administrateur/Documents/TurboGraph_V2/Langage/test.txt");
    // On ouvre notre fichier en lecture seule et on vérifie l'ouverture
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return;

    // Création d'un objet QTextStream à partir de notre objet QFile
    QTextStream flux(&file);
    // Écriture des différentes lignes dans le fichier
    flux << ui->function->toPlainText();


    system ("start C:\\Users\\Administrateur\\Documents\\TurboGraph_V2\\Langage\\langage.exe");

    QVector<double> x, y;

    ifstream monFlux("C:/Users/Administrateur/Documents/TurboGraph_V2/Langage/points.txt");  //Ouverture d'un fichier en lecture

    if(monFlux){
        string line;
        string ix;
        string ygrec;
        while(getline(monFlux, line)){
            int addr = line.find(' ');
            ix = line.substr(0, addr);
            ygrec = line.substr(addr, line.length());
            cout << ix << " " << ygrec << endl;
            x.push_front(stod(ix));
            y.push_front(stod(ygrec));
        }

    }
    else
    {
        cout << "ERREUR: Impossible d'ouvrir le fichier en lecture." << endl;
    }

    ui->customPlot->graph(0)->setData(x,y);
    ui->customPlot->rescaleAxes();
    ui->customPlot->replot();
}

