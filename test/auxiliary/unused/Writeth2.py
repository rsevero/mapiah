#!/usr/bin/python

##
## Copyright (C) 2011-2013 Andrew Atkinson
##
##-------------------------------------------------------------------
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##-------------------------------------------------------------------

from __future__ import unicode_literals

#import codecs
import io as cStringIO
import os
import re

import CheckerCreate


def legstostnshot(pos, firststn, pore):
    ''' works out station coordinates and shots
        end coordinates form leg information
    '''
    stnorphan = []
    XVIshots = []
    shotsorphan = []
    #set the first station at 0,0
    XVIstations = {firststn: [0, 0, firststn]}
    for shot in pos:
#        print(shot)
        x, y = shot[pore]
        #for splays must have a station position,
        #work out shot, else Controller as orphan
        if shot['to'] == '-':
            if shot['from'] in XVIstations:
                fromx = XVIstations[shot['from']][0]
                fromy = XVIstations[shot['from']][1]
                tox = fromx + x
                toy = fromy + y
                #build shot
                s = [fromx, fromy, tox, toy]
            else:
                shotsorphan.append(shot)
        #For legs try the from, then the to, if not then orphan.
        #Work out station coordinates.
        else:
            if shot['from'] in XVIstations:

                startx = XVIstations[shot['from']][0]
                starty = XVIstations[shot['from']][1]
                stnx = startx + x
                stny = starty + y
                XVIstations[shot['to']] = [stnx, stny, shot['to']]
                s = [startx, starty, stnx, stny]
            elif shot['to'] in XVIstations:
                startx = XVIstations[shot['to']][0]
                starty = XVIstations[shot['to']][1]
                stny = starty - y
                # On elevation the x is controlled by direction already accounted for
                #when calculating the relative positions
                if pore == 'elev':
                    stnx = startx + x
                else:
                    stnx = startx - x
                XVIstations[shot['from']] = [stnx, stny, shot['from']]
                s = [startx, starty, stnx, stny]
            else:
                stnorphan.append(shot)
                print('''The survey  line\n {0} {1}\n appears not have a previously connected sation,
Trying to continue with out it'''.format (shot['from'],  shot['to']))
        ###Need to deal with orphans every time!!! currently ignored
        #Add it in as a shot
        XVIshots.append(s)
    return {'stations': XVIstations, 'shots': XVIshots}


def stn_connect(drawing, stations, xsec):
    '''replaces stn name with coordinates for connect lines'''
    #xsec is [x y stn dir]
    #stations {stn: [x y stn]}
    #drawing [colour:line type, coord :[{x:x1, y:y1}, {x:x2, y:y2}......]]

##todo: catch error for incorrect key, probably caused by renumbering of data
#and xsections not being correctly numbered, still an error in v0.371
    for sec in xsec:
        try:
            x1 = sec[0]
            x2 = stations[sec[2]][0]
            y1 = sec[1]
            y2 = stations[sec[2]][1]
            drawing.append({'colour': 'connect',
                            'coord': [{'x': x1, 'y': y1}, {'x': x2, 'y': y2}]})
        except:
            print('''The cross section {!r} is not connected to a previous station -
Missing it out'''.format(sec[2]))
    return drawing


def maxmins(x, y, maxmin):
    if x < maxmin['minx']:
        maxmin['minx'] = x
    elif x > maxmin['maxx']:
        maxmin['maxx'] = x
    if y < maxmin['miny']:
        maxmin['miny'] = y
    elif y > maxmin['maxy']:
        maxmin['maxy'] = y
    return maxmin


def XVIwrite(cfactor, grid, XVIstations1, XVIshots1,
             XVIpathname, settings, **kwargs):
    #kwargs are sketches, xsecstn, xsecsplays
    maxmin = {'minx': 0, 'miny': 0, 'maxx': 0, 'maxy': 0}
    #print(XVIpathname)
#    with open(XVIpathname, 'w') as pXVIfile:
    pXVIfile = cStringIO.StringIO()
    pXVIfile.write('set XVIgrids {' + str(grid) + ' m}\nset XVIstations {\n')
    #Write the plan stations
    for k, s in XVIstations1.items():
        maxmin = maxmins(s[0], s[1], maxmin)
        pXVIfile.write('\t{')
        pXVIfile.write(str(round((s[0] * cfactor), 2))
                       + ' ' + str(round((s[1] * cfactor), 2)) + ' ' + str(s[2]))
        pXVIfile.write('}\n')
    if kwargs:
        #Write the xsec stations
        for st in kwargs['xsecstn']:
            #st is [x y stn direction]
            maxmin = maxmins(st[0], st[1], maxmin)
            pXVIfile.write('\t{')
            pXVIfile.write(str(round((st[0] * cfactor), 2))
                           + ' ' + str(round((st[1] * cfactor), 2))
                           + ' ' + str(st[2]))
            pXVIfile.write('}\n')
        #write the shots
    pXVIfile.write('}\nset XVIshots {\n')
        #print(XVIshots1)
        #print(xsecsplays)
    for sh in  (XVIshots1):
        pXVIfile.write('\t{')
        for x, y in zip(sh[::2], sh[1::2]):
            maxmin = maxmins(x, y, maxmin)
            pXVIfile.write(' ' + str(round((x * cfactor), 2))
                           + ' ' + str(round((y * cfactor), 2)))
        pXVIfile.write('}\n')
    if kwargs:
        for s in  kwargs['xsecsplays']:
            pXVIfile.write('\t{')
            for x, y in zip(s[::2], s[1::2]):
                maxmin = maxmins(x, y, maxmin)
                pXVIfile.write(' ' + str(round((x * cfactor), 2))
                               + ' ' + str(round((y * cfactor), 2)))
            pXVIfile.write('}\n')
    pXVIfile.write('}\nset XVIsketchlines {\n')
    if kwargs:
        for line in  kwargs['sketches']:
            pXVIfile.write('\t{' + line['colour'])
            for c in line['coord']:
                maxmin = maxmins(c['x'], c['y'], maxmin)
                pXVIfile.write(' ' + str(round((c['x'] * cfactor), 2))
                               + ' ' + str(round((c['y'] * cfactor), 2)))
            pXVIfile.write('}\n')

    pXVIfile.write('}\nset XVIgrid {')
    #calculate grid size
    width = maxmin['maxx'] - maxmin['minx']
    height = maxmin['maxy'] - maxmin['miny']
    xsquares = str(round(width) + 2)
    ysquares = str(round(height) + 2)
    #Grid is{bottom left x, bottom left y,
    #x1 dist, y1 dist, x2 dist, y2 dist, number of x, number of y}
    pXVIfile.write(str((maxmin['minx'] - 1) * cfactor)
                    + " " + str((maxmin['miny'] - 1) * cfactor)
                    + " " + str(grid * cfactor)
                    + " 0.0 0.0 " + str(grid * cfactor)
                    + " " + xsquares + " " + ysquares + "}")
    CheckerCreate.CreateFile(XVIpathname, pXVIfile, settings['overwrite'],
                                settings['add2rep'], settings['repository'])
    return maxmin


def th2write(firststn, maxmin, surveypathname,
             cfactor, relXVIloc, th2file):
    #surveypathname =  os.path.join(surveydir, surveyname+'.th2')
    #Create a border of 10% on each side (20%)
    width = maxmin['maxx'] - maxmin['minx']
    height = maxmin['maxy'] - maxmin['miny']
    wborder = 0.2 * width
    hborder = 0.2 * height
    #therion expects linux / in file names, so change to that
    relXVIloc = re.sub(r'\\', '/', relXVIloc)
    th2file.write('encoding  utf-8\n##XTHERION## xth_me_area_adjust '
                  + str(round(((-1 * wborder) * cfactor), 2)) + ' '
                  + str(round(((-1 * hborder) * cfactor), 2)) + ' '
                  + str(round(((width + wborder) * cfactor), 2)) + ' '
                  + str(round(((height + hborder) * cfactor), 2))
                  + '\n##XTHERION## xth_me_area_zoom_to 50\n')
    th2file.write('##XTHERION## xth_me_image_insert {'
                  + str((-1 * maxmin['minx'] + (wborder) / 2) * cfactor) + ' '
                  + '1 1.0} {' + str((-1 * maxmin['miny'] + (hborder) / 2) * cfactor)
                  + ' ' + firststn + '} ' + relXVIloc + ' 0 {}\n\n')
    return


def th2scrap(name, projection, cfactor, th2file):
    '''Adds one scrap line in'''
    th2file.write('\nscrap ' + name + ' -projection [' + projection + '] -scale [0 0 '
                  + (str(round((10 * cfactor), 2)) + ' ') * 2
                  + ' 0 0 10 10 m]\n\nendscrap\n\n')
    return


def th2plan(relcoord, settings, outline, firststn, locations, pore):
    """th2 for the plan and the associated XVI file"""
    pos = relcoord['stnpos']
    xsecsplays = relcoord['xsecsplays']
    planscale = settings['planscale']
    planDPI = settings['planDPI']
    #Conversion Factor:
    #XVI works in planDPI so multiply by inches in metre (100/2.54)
    cfactor = 100 * planDPI / (2.54 * planscale)
    #firststn = pos[0]['from']
    #Station posision and shots from leg information
    XVIss = legstostnshot(pos, firststn, pore)
    #Use the relative position of stations to fill in the
    #coordinates of the connect lines.
    outline['polys'] = stn_connect(outline['polys'], XVIss['stations'], outline['xsec'])
    #output the files
    XVIpathname = os.path.join(locations['rawdir'],
                               locations['surveyname'] + '_p.xvi')
    relXVIloc = os.path.relpath(XVIpathname, locations['surveydir'])
    maxmin = XVIwrite(cfactor, settings['plangrid'], XVIss['stations'], XVIss['shots'],
                      XVIpathname, settings,
                      sketches=outline['polys'],
                      xsecstn=outline['xsec'],
                      xsecsplays=xsecsplays['plan'])
    surveypathname = os.path.join(locations['surveydir'],
                                   locations['surveyname'] +
                                   settings['plansuffix'] + '.th2')
    th2file = cStringIO.StringIO()
    th2write(firststn, maxmin, surveypathname,
             cfactor, relXVIloc, th2file)
    if settings['ins_pscraps']:
        for n in range(1, int(settings['pscraps']) + 1):
            name = locations['surveyname'] + settings['pscrapsuffix'] + str(n)
            th2scrap(name, 'plan', cfactor, th2file)
    if settings['ins_pxscraps']:
        for m in outline['xsec']:
            name = locations['surveyname'] + settings['planxsuffix'] + m[2]
            th2scrap(name, 'none', cfactor, th2file)
    #Python does not seem to be adding the required 0A (\n) to end
    #Doing it manually
    th2file.write("\x0a")
    CheckerCreate.CreateFile(surveypathname, th2file, settings['overwrite'],
                                settings['add2rep'], settings['repository'])


def th2elev(relcoord, settings, sideview, firststn, locations, pore):
    """th2 for the elev and the associated XVI file"""
    pos = relcoord['stnpos']
    xsecsplays = relcoord['xsecsplays']
    elevscale = settings['elevscale']
    elevDPI = settings['elevDPI']
    #Conversion Factor:
    #XVI works in planDPI so multiply by inches in metre (100/2.54)
    cfactor = 100 * elevDPI / (2.54 * elevscale)
    #Station posision and shots from leg information
    XVIss = legstostnshot(pos, firststn, pore)
    #Use the relative position of stations to fill in the
    #coordinates of the connect lines.
    sideview['polys'] = stn_connect(sideview['polys'], XVIss['stations'],
                                    sideview['xsec'])
    #output the files
    XVIpathname = os.path.join(locations['rawdir'],
                               locations['surveyname'] + '_e.xvi')
    relXVIloc = os.path.relpath(XVIpathname, locations['surveydir'])
    maxmin = XVIwrite(cfactor, settings['elevgrid'], XVIss['stations'], XVIss['shots'],
                      XVIpathname, settings,
                      sketches=sideview['polys'],
                      xsecstn=sideview['xsec'],
                      xsecsplays=xsecsplays['elev'])
    surveypathname = os.path.join(locations['surveydir'],
                                   locations['surveyname'] +
                                   settings['elevsuffix'] + '.th2')
    th2file = cStringIO.StringIO()
    th2write(firststn, maxmin, surveypathname,
             cfactor, relXVIloc, th2file)
    if settings['ins_escraps']:
        for n in range(1, int(settings['escraps']) + 1):
            name = locations['surveyname'] + settings['escrapsuffix'] + str(n)
            th2scrap(name, 'extended', cfactor, th2file)
    if settings['ins_exscraps']:
        for m in sideview['xsec']:
            if m[3] == -1:
                name = locations['surveyname'] + settings['elevpxsuffix'] + m[2]
            else:
                name = locations['surveyname'] + settings['elevvxsuffix'] + m[2]
            th2scrap(name, 'none', cfactor, th2file)
    #Python does not seem to be adding the required 0A (\n) to end
    #Doing it manually
    th2file.write("\x0a")
    CheckerCreate.CreateFile(surveypathname, th2file, settings['overwrite'],
                                settings['add2rep'], settings['repository'])


def th2file(pore, locations, suffix, scale, DPI, pos,
                firststn, grid, settings, **kwargs):
    """th2 for the elev and the associated XVI file"""
    ins_xscraps = kwargs.get('ins_xscraps', False)
    #Conversion Factor:
    #XVI works in planDPI so multiply by inches in metre (100/2.54)
    cfactor = 100 * DPI / (2.54 * scale)
    #firststn = pos[0]['from']
    #Station posision and shots from leg information
    XVIss = legstostnshot(pos, firststn, pore)
    #Use the relative position of stations to fill in the
    #coordinates of the connect lines.
    if 'sideview' in kwargs:
        sideview['polys'] = stn_connect(sideview['polys'], XVIss['stations'],
                                        sideview['xsec'])
    #output the files
    XVIpathname = os.path.join(locations['rawdir'],
                               locations['surveyname'] + '_'
                               + suffix + '.xvi')
    relXVIloc = os.path.relpath(XVIpathname, locations['surveydir'])
    maxmin = XVIwrite(cfactor, grid, XVIss['stations'], XVIss['shots'],
                      XVIpathname, settings)
    surveypathname = os.path.join(locations['surveydir'],
                                   locations['surveyname'] +
                                   suffix + '.th2')
    th2file = cStringIO.StringIO()
    th2write(firststn, maxmin, surveypathname,
             cfactor, relXVIloc, th2file)
    if kwargs:
        type = {'plan': 'plan', 'elev': 'extended',
               'proj': 'elevation ' + str(kwargs['pangle'])}
        if kwargs['ins_scraps']:
            for n in range(1, int(kwargs['ins_scraps']) + 1):
                name = locations['surveyname'] + kwargs['scrapsuffix'] + str(n)
                th2scrap(name, type[pore], cfactor, th2file)
        if ins_xscraps:
            for m in sideview['xsec']:
                if m[3] == -1:
                    name = locations['surveyname'] + kwargs['xpsuffix'] + m[2]
                else:
                    name = locations['surveyname'] + kwargs['xsuffix'] + m[2]
                th2scrap(name, 'none', cfactor, th2file)
    #Python does not seem to be adding the required 0A (\n) to end
    #Doing it manually
    th2file.write("\x0a")
    CheckerCreate.CreateFile(surveypathname, th2file, settings['overwrite'],
                                settings['add2rep'], settings['repository'])
