//
//  Render.swift
//  PathTracing-Demo
//
//  Created by N.Ishida on 6/2/18.
//

import Foundation
import simd

class Render {
  let width:Int
  let height:Int
  let samples:Int
  let superSapmles:Int

  private(set) var camera_pos = double3(50,52,220)
  private(set) var camera_dir = normalize(double3(0,-0.04,-1))
  private(set) var camera_up  = double3(0,1,0)

  private(set) var screen_width:double_t = 0
  private(set) var screen_height:double_t = 0
  private(set) var screen_dist:double_t = 40

  private(set) var screen_x = double3(0)
  private(set) var screen_y = double3(0)
  private(set) var screen_center = double3(0)


  init(width:Int,height:Int,samples:Int,superSample:Int) {
    self.width = width
    self.height = height
    self.samples = samples
    self.superSapmles = superSample
  }

  func setCameraProp(pos:double3,dir:double3,up:double3) {
    camera_pos = pos
    camera_dir = dir
    camera_up  = up
  }

  private func setScreen() {
    screen_width = 30*double_t(width)/double_t(height)
    screen_height = 30
    screen_x = normalize(cross(camera_dir, camera_up))*screen_width
    screen_y = normalize(cross(screen_x, camera_dir))*screen_height
    screen_center = camera_pos+camera_dir*screen_dist
  }

  func renderImage(radiance:Radiance) {
    setScreen()

    var pixels:[[Color]] = Array(repeating: Array(repeating: Color(0), count: width), count: height)
    var sampled:Int = 1
    for sm in 0..<samples {
      let rate = String(format: "%.2f", arguments: [double_t(sm)/double_t(samples)*100])
      print("Rendering sample \(sm)/\(samples) " + rate + "%")
      for y in 0..<height {
        for x in 0..<width {
          var accumulatedRadiance = Color(0)
          for sy in 0..<superSapmles {
            for sx in  0..<superSapmles {

              let rate:double_t = 1/double_t(superSapmles)
              let r1:double_t = double_t(sx)*rate / rate*2
              let r2:double_t = double_t(sy)*rate / rate*2

              let xOffset:double3 = screen_x*((r1+double_t(x))/double_t(width)-0.5)
              let yOffset:double3 = screen_y*((r2+double_t(y))/double_t(height)-0.5)
              let posOnScreen:double3 = screen_center + xOffset + yOffset

              let rayDir:double3 = normalize(posOnScreen - camera_pos)

              let nextRay = Ray(camera_pos, rayDir)
              accumulatedRadiance += radiance.calcRadiance(ray: nextRay, depth: 0) / double_t(superSapmles*superSapmles)
            }
          }
          pixels[y][x] = (pixels[y][x]*double_t(sampled-1)+accumulatedRadiance)/double_t(sampled)
        }
      }
      sampled += 1
      writeToImage(pixels: pixels, name: "PathTracing-Demo.png")
    }
    writeToImage(pixels: pixels, name: "PathTracingComplete.png")

  }

  func writeToImage(pixels:[[Color]], name:String) {
    let width:Int = pixels[0].count
    let height:Int = pixels.count
    let writer = ImageWriter(width: width, height: height, name: name)
    for y in 0..<height {
      for x in 0..<width {
        //FIXME: 整理されていない
        var col:Color = pixels[y][x]
        col = Color(pow(col.x, 1/2.2),pow(col.y, 1/2.2),pow(col.z, 1/2.2))
        //上下逆
        writer.data[x][height-y-1] = ImageWriter.Color(Red: col.x, Green: col.y, Blue: col.z)
      }
    }
    writer.makeImage()
  }
}










